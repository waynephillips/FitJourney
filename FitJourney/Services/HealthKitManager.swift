import Foundation
import HealthKit
import SwiftUI

// MARK: - HealthKitManager
// @Observable @MainActor singleton-style class providing HealthKit read/write
// for FitJourney. Injected via SwiftUI Environment from FitJourneyApp.

@Observable
@MainActor
final class HealthKitManager {

    // MARK: - Auth State

    enum AuthStatus { case notDetermined, authorized, denied, unavailable }

    var authStatus: AuthStatus = HKHealthStore.isHealthDataAvailable() ? .notDetermined : .unavailable
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: - Fetched Values

    var latestWeightLbs: Double?
    var weightHistory: [(date: Date, lbs: Double)] = []
    var todaySteps: Int = 0
    var todayCalories: Double = 0

    // MARK: - Private

    private let store = HKHealthStore()

    private static let readTypes: Set<HKObjectType> = [
        HKQuantityType(.bodyMass),
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.heartRate),
        HKQuantityType(.distanceWalkingRunning)
    ]

    private static let writeTypes: Set<HKSampleType> = [
        HKQuantityType(.bodyMass),
        HKObjectType.workoutType()
    ]

    // MARK: - Authorization

    func requestAuthorization() async {
        guard isAvailable else { authStatus = .unavailable; return }
        do {
            try await store.requestAuthorization(
                toShare: Self.writeTypes,
                read: Self.readTypes
            )
            authStatus = .authorized
            await fetchAll()
        } catch {
            authStatus = .denied
        }
    }

    // MARK: - Fetch All

    func fetchAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchLatestWeight() }
            group.addTask { await self.fetchWeightHistory(days: 90) }
            group.addTask { await self.fetchTodaySteps() }
            group.addTask { await self.fetchTodayCalories() }
        }
    }

    // MARK: - Weight

    func fetchLatestWeight() async {
        let type = HKQuantityType(.bodyMass)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let result: Double? = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]
            ) { _, samples, _ in
                let lbs = (samples?.first as? HKQuantitySample)?
                    .quantity.doubleValue(for: .pound())
                continuation.resume(returning: lbs)
            }
            store.execute(query)
        }
        latestWeightLbs = result
    }

    func fetchWeightHistory(days: Int) async {
        let type = HKQuantityType(.bodyMass)
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let pairs: [(Date, Double)] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type, predicate: pred,
                limit: HKObjectQueryNoLimit, sortDescriptors: [sort]
            ) { _, samples, _ in
                let result = (samples as? [HKQuantitySample] ?? []).map {
                    ($0.startDate, $0.quantity.doubleValue(for: .pound()))
                }
                continuation.resume(returning: result)
            }
            store.execute(query)
        }
        weightHistory = pairs.map { (date: $0.0, lbs: $0.1) }
    }

    func saveWeight(_ lbs: Double) async throws {
        let type = HKQuantityType(.bodyMass)
        let sample = HKQuantitySample(
            type: type,
            quantity: HKQuantity(unit: .pound(), doubleValue: lbs),
            start: Date(), end: Date()
        )
        try await store.save(sample)
        latestWeightLbs = lbs
    }

    // MARK: - Steps

    func fetchTodaySteps() async {
        let type = HKQuantityType(.stepCount)
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())
        let count: Int = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: pred,
                options: .cumulativeSum
            ) { _, stats, _ in
                let val = Int(stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                continuation.resume(returning: val)
            }
            store.execute(query)
        }
        todaySteps = count
    }

    // MARK: - Calories

    func fetchTodayCalories() async {
        let type = HKQuantityType(.activeEnergyBurned)
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())
        let cals: Double = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: pred,
                options: .cumulativeSum
            ) { _, stats, _ in
                let val = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: val)
            }
            store.execute(query)
        }
        todayCalories = cals
    }

    // MARK: - Save Workout

    func saveWorkout(planName: String, startTime: Date, endTime: Date) async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        config.locationType = .indoor

        let builder = HKWorkoutBuilder(
            healthStore: store,
            configuration: config,
            device: .local()
        )

        try await builder.beginCollection(at: startTime)
        try await builder.endCollection(at: endTime)

        // finishWorkout uses a completion handler; wrap for async/await
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            builder.finishWorkout { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
