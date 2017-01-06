//
//  HealthKitGraphVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 23..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import SwiftCharts
import HealthKit

class HealthKitGraphVC: UIViewController {
    
    private var chart: Chart? = nil
    private var heartRateDicKey = [String]() // [date]
    private var heartRateDic = [String: [Int]]() // date: [value]
    private let dateFormatter = DateFormatter()
    
    @IBOutlet weak var lastHeartRate: UILabel!
    @IBOutlet weak var minHeartRate: UILabel!
    @IBOutlet weak var maxHeartRate: UILabel!
    @IBOutlet weak var lastDate: UILabel!
    @IBOutlet weak var lastTime: UILabel!
    @IBOutlet weak var chartView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateFormatter.dateFormat = "MM. dd"
        print("=================== viewWillAppear ===================")
        self.chartView.backgroundColor = UIColor.white
        self.setDataArea()
        self.setLastHeartRateData()
        //dump(self.heartRateDic)
        if chart == nil {
            chart = self.barsChart()
            chart?.view.translatesAutoresizingMaskIntoConstraints = true
        } else {
            chart?.clearView()
            chart = self.barsChart()
        }
        self.chartView.addSubview((chart?.view)!)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        print("=================== viewWillLayoutSubview ===================")
        //print("\nchartView.bounds: \(self.chartView.bounds)\nchartView.frmae: \(self.chartView.frame)")
        if chart == nil {
            chart = self.barsChart()
            chart?.view.translatesAutoresizingMaskIntoConstraints = true
        } else {
            chart?.clearView()
            chart = self.barsChart()
        }
        self.chartView.addSubview((chart?.view)!)
    }
    
    func showChart() {
//        print("=================== showChart ===================")
        if self.chart == nil {
            self.chart = self.barsChart()
            
            //self.chart?.view.translatesAutoresizingMaskIntoConstraints = true
        } else {
            self.chart?.clearView()
            self.chart = self.barsChart()
        }
        self.chartView.addSubview((chart?.view)!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func barsChart() -> Chart? {
        //print("=================== basrChart ===================")
        let labelSettings = ChartLabelSettings(font: ChartsDefaultSetting.labelFont)
        
        var barsData = [(title: String, min: Double, max: Double)]()
        
        for key in self.heartRateDicKey.reversed() {
            if let min = self.heartRateDic[key]?.min(), let max = self.heartRateDic[key]?.max() {
                barsData.append((key, Double(min), Double(max)))
            } else {
                barsData.append((key, 0, 0))
            }
        }
        
        let alpha: CGFloat = 1
        let posColor = UIColor(displayP3Red: 241/255, green: 156/255, blue: 96/255, alpha: 1)
        let negColor = UIColor(displayP3Red: 248/255, green: 212/255, blue: 156/255, alpha: 1)
        let zero = ChartAxisValueDouble(0)
        let bars: [ChartBarModel] = barsData.enumerated().flatMap {index, tuple in
            [
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.max), bgColor: posColor),
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.min), bgColor: negColor)
            ]
        }
        
        let yValues = stride(from: 0, through: 200, by: 20).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
        let xValues =
            [ChartAxisValueString(order: -1)] +
                barsData.enumerated().map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
                [ChartAxisValueString(order: barsData.count)]
        
        let xModel = ChartAxisModel(axisValues: xValues)
        let yModel = ChartAxisModel(axisValues: yValues)

        let chartFrame = ChartsDefaultSetting.chartFrame(containerBounds: chartView.bounds)

//        let chartFrame = CGRect(x: 0, y: 0, width: self.chartView.frame.width, height: self.view.frame.height/7*3)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ChartsDefaultSetting.chartSetting, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let barsLayer = ChartBarsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: false, barWidth: 20, animDuration: 0.5)
        
//        print("chartFrame: \(chartFrame) \nchartView.frame: \(chartView.frame)")
        
        // labels layer
        // create chartpoints for the top and bottom of the bars, where we will show the labels
        let labelChartPoints = bars.map {bar in
            ChartPoint(x: bar.constant, y: bar.axisValue2)
        }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let labelsLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: labelChartPoints, viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let label = HandlingLabel()
            let posOffset: CGFloat = 10
            
            let pos = chartPointModel.chartPoint.y.scalar > 0
            
            let yOffset = pos ? posOffset : -posOffset
            label.text = "\(formatter.string(from: NSNumber(value: chartPointModel.chartPoint.y.scalar))!)"
            label.font = ChartsDefaultSetting.labelFont
            label.sizeToFit()
            label.center = CGPoint(x: chartPointModel.screenLoc.x, y: pos ? innerFrame.origin.y : innerFrame.origin.y + innerFrame.size.height)
            label.alpha = 0
            
            label.movedToSuperViewHandler = {[weak label] in
                UIView.animate(withDuration: 0.3, animations: {
                    label?.alpha = 1
                    label?.center.y = chartPointModel.screenLoc.y + yOffset
                })
            }
            return label
            
            }, displayDelay: 0.5) // show after bars animation
        
        // show a gap between positive and negative bar
        let dummyZeroYChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
        let yZeroGapLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: [dummyZeroYChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let height: CGFloat = 2
            let v = UIView(frame: CGRect(x: innerFrame.origin.x + 2, y: chartPointModel.screenLoc.y - height, width: innerFrame.origin.x + innerFrame.size.height, height: height))
            //v.backgroundColor = UIColor.whiteColor()
            return v
        })
        
        let chart: Chart? = Chart(
            frame: chartFrame,
            //frame: CGRect(x: 0,y: 0, width: 375.5, height: 667),
            layers: [
                xAxis,
                yAxis,
                barsLayer,
                labelsLayer,
                yZeroGapLayer,
//                lineLayer,
//                lineCirclesLayer
            ]
        )
        
        return chart
    }

    func setDataArea() {
        self.heartRateDicKey.removeAll()

        let calcDate = Calendar.current.date(byAdding: Calendar.Component.day, value: -6, to: Date())!
        for i in 0...6 {
            let date = Calendar.current.date(byAdding: Calendar.Component.day, value: -i, to:Date())!
            let stringDate = self.dateFormatter.string(from: date)
            self.heartRateDicKey.append(stringDate)
            self.heartRateDic[stringDate] = [Int]()
        }
        
        for heartRate in heartRates {
            guard calcDate < heartRate.startDate else {
                break
            }
            let dateString = self.dateFormatter.string(from: heartRate.startDate)

            self.heartRateDic[dateString]?.append(Int(heartRate.quantity.doubleValue(for: bpmUnit)))
        }
        self.heartRateDicKey = self.heartRateDicKey.sorted().reversed()
//        dump(self.heartRateDicKey)
    }
    
    func setLastHeartRateData() {
        guard let lastHeartrate = heartRates.first else {
            self.lastHeartRate?.text = "-bpm"
            self.lastDate?.text = "-"
            self.lastTime?.text = "-"
            return
        }
        let dateString = dateFormatter.string(from: lastHeartrate.startDate)
        guard let minValue = self.heartRateDic[dateString]?.min(), let maxValue = self.heartRateDic[dateString]?.max() else {
            self.minHeartRate?.text = "-"
            self.maxHeartRate?.text = "-"
            return
        }
        
        
        self.lastHeartRate?.text = "\(Int(lastHeartrate.quantity.doubleValue(for: bpmUnit)))bpm"
        
        self.minHeartRate?.text = "\(minValue)"
        self.maxHeartRate?.text = "\(maxValue)"
        
        self.lastDate?.text = {
            let lastDateFormatter = DateFormatter()
            lastDateFormatter.dateFormat = "YY.MM.dd"
            return lastDateFormatter.string(from: lastHeartrate.startDate)
        }()
        
        self.lastTime?.text = {
            let lastTimeFormatter = DateFormatter()
            lastTimeFormatter.dateFormat = "a hh:mm"
             return lastTimeFormatter.string(from: lastHeartrate.startDate)
        }()
    }
    
    
    @IBAction func showAllHeartRates(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "chartToAllHealthKitData", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
