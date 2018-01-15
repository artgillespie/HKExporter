//
//  ViewController.swift
//  HKExporter
//
//  Created by Art Gillespie on 1/13/18.
//  Copyright © 2018 tapsquare. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    var store: HKHealthStore!
    
    func getWorkouts() {
        print("HealthStore: \(store)")
        let type = HKSampleType.workoutType()
        /*
        let distance = HKQuantity(unit: HKUnit.mile(), doubleValue: 0.1)
        let predicate = HKQuery.predicateForWorkouts(with: .greaterThanOrEqualTo, totalDistance: distance)
        */
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy/MM/dd"
        let startDate = dateF.date(from: "2017/01/15")
        print("startDate \(startDate!)")
        let whenPredicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [runningPredicate, whenPredicate])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 500, sortDescriptors: nil) { (q, samples, error) in
            if (error != nil ) {
                print("Error: \(error!)")
                return
            }
            print("samples: \(samples!.count)")
            var total = 0.0
            for w in samples! {
                let workout = w as! HKWorkout
                print("\(workout.startDate)")
                print("\(workout.duration)")
                total += workout.totalDistance!.doubleValue(for: HKUnit.mile())

                print("\(workout.totalDistance!)")
                print("\(workout.workoutActivityType)")
            }
            print("\(total) miles running")
        }
        store.execute(query)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!HKHealthStore.isHealthDataAvailable()) {
            print("Health Data Not Available!")
            return
        }
        store = HKHealthStore()
        store.requestAuthorization(toShare: nil, read: [HKObjectType.workoutType()]) { (authorized, error) in
            guard authorized else {
                print("Error Requesting Authorization: \(error!)")
                return
            }
            print("Authorization ok! Querying...")
            self.getWorkouts()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

