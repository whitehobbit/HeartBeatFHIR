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
    private var chart: Chart?
    private var heartRateKey = [String]()
    private var heartRatesDic = [String : [String : Int]]() //
    
//    TODO: - 아래 데이터 구조로의 변환이 필요
    var heartRateDicKey = [String]() // [date]
    var heartRateDic = [String: [Int]]() // date: [value]
    var healthDic = [String: [HKQuantitySample]]()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter
    }()
    
    @IBOutlet weak var lastHeartRate: UILabel!
    @IBOutlet weak var minHeartRate: UILabel!
    @IBOutlet weak var maxHeartRate: UILabel!
    @IBOutlet weak var lastDate: UILabel!
    @IBOutlet weak var lastTime: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var healthKitTabBarItem: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("=================== viewWillAppear ===================")
        self.chartView.backgroundColor = UIColor.white
        self.setDataArea()
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
        print("=================== viewWillLayoutSubview ===================")
        print("\nchartView.bounds: \(self.chartView.bounds)\nchartView.frmae: \(self.chartView.frame)")
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
        print("=================== showChart ===================")
        if self.chart == nil {
            self.chart = self.barsChart()
            
            //self.chart?.view.translatesAutoresizingMaskIntoConstraints = true
        } else {
            self.chart?.clearView()
            self.chart = self.barsChart()
        }
        self.chartView.addSubview((chart?.view)!)
        
//        chart?.view.center = CGPoint(x: chartView.bounds.midX, y: chartView.bounds.midY)
//        chart?.view.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func barsChart() -> Chart? {
        print("=================== basrChart ===================")
        
        print("chartView.frame: \(chartView.frame) \nchartView.bounds: \(self.chartView.bounds)")
        
        let labelSettings = ChartLabelSettings(font: ChartsDefaultSetting.labelFont)
        
        let barsData: [(title: String, min: Double, max: Double)] = {
            var data = [(title: String, min: Double, max: Double)]()
            data.removeAll()
            for key in self.heartRateKey.reversed() {
                data.append((key, Double(self.heartRatesDic[key]!["min"]!), Double(self.heartRatesDic[key]!["max"]!)))
            }
            return data
        }()
        
        let alpha: CGFloat = 1
        let posColor = UIColor.orange.withAlphaComponent(alpha)
        let negColor = UIColor.green.withAlphaComponent(alpha)
        let zero = ChartAxisValueDouble(30)
        let bars: [ChartBarModel] = barsData.enumerated().flatMap {index, tuple in
            [
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.max), bgColor: posColor),
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.min), bgColor: negColor)
            ]
        }
        
        let yValues = stride(from: 30, through: 160, by: 10).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
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
        
        print("chartFrame: \(chartFrame) \nchartView.frame: \(chartView.frame)")
        
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
            
            let yOffset = pos ? -posOffset : posOffset
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
        var cnt = 0
        var beforeDate: String? = nil
        var minHeartRate: Int? = nil
        var maxHeartRate: Int? = nil
        self.heartRateKey.removeAll()
        for heartRate in heartRates {
            //print("\(cnt) : \(heartRates.count)")
            if cnt > 6 || cnt > heartRates.count {
                break
            }
            else {
                let lastHeartRate = Int(heartRate.quantity.doubleValue(for: bpmUnit))
                let lastDate: String? = self.dateFormatter.string(from: heartRate.startDate)
                
                if beforeDate == nil { // 처음일 경우
                    
                    //print("\n\(cnt) : \(heartRate.quantity.doubleValue(for: bpmUnit)), \(self.dateFormatter.string(from: heartRate.startDate))")
                    beforeDate = lastDate
                    minHeartRate = lastHeartRate
                    maxHeartRate = lastHeartRate
                    
                    if lastHeartRate != nil {
                        self.lastHeartRate?.text = "\(lastHeartRate)bpm"
                    } else {
                        self.lastHeartRate?.text = "-bpm"
                    }
                    
                    let lastDateFormat: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "YY.MM.dd"
                        return formatter
                    }()
                    
                    let lastTimeFormat: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "a hh:mm"
                        return formatter
                    }()
                    
                    self.lastDate?.text = "\(lastDateFormat.string(from: heartRate.startDate))"
                    self.lastTime?.text = "\(lastTimeFormat.string(from: heartRate.startDate))"
                    
                } else { // 처음이 아닐 경우
                    if beforeDate != lastDate { // 측정 날짜가 변경될 경우
                        self.heartRateKey.append(beforeDate!)
                        self.heartRatesDic[beforeDate!] = ["min" : minHeartRate!, "max" : maxHeartRate!]
                        
                        //print("\(cnt) \(beforeDate) \(lastDate) ")
                        
                        beforeDate = lastDate
                        minHeartRate = lastHeartRate
                        maxHeartRate = minHeartRate
                        cnt = cnt + 1
                    }
                    
                    //print("\(cnt) : \(heartRate.quantity.doubleValue(for: bpmUnit)), \(self.dateFormatter.string(from: heartRate.startDate))")
                    minHeartRate = (minHeartRate! > lastHeartRate) ? lastHeartRate : minHeartRate
                    maxHeartRate = (maxHeartRate! < lastHeartRate) ? lastHeartRate : maxHeartRate
                    
                    if heartRate.startDate == heartRates.last?.startDate { // 마지막 측정일 경우
                        
                        self.heartRateKey.append(lastDate!)
                        self.heartRatesDic[lastDate!] = ["min" : minHeartRate!, "max" : maxHeartRate!]
                        
                        //print("\(cnt) \(beforeDate) \(lastDate) ")
                        
                        beforeDate = lastDate
                        minHeartRate = lastHeartRate
                        maxHeartRate = minHeartRate
                    }
                }
            }
        }
        
        //print("\(self.heartRatesDic[heartRateKey[0]])")
        //print("\(self.heartRatesDic[heartRateKey[1]])")
        
        //print("keyCount \(self.heartRateKey.count)")
        //print("dicCount \(self.heartRatesDic.count)")
        if !self.heartRatesDic.isEmpty {
            self.minHeartRate?.text = "\(self.heartRatesDic[self.heartRateKey[0]]!["min"]!)"
            self.maxHeartRate?.text = "\(self.heartRatesDic[self.heartRateKey[0]]!["max"]!)"
            
        } else {
            self.lastHeartRate?.text = "-bpm"
            self.minHeartRate?.text = "-"
            self.maxHeartRate?.text = "-"
            self.lastDate?.text = "-"
            self.lastTime?.text = "-"
        }
        
        
        //self.heartRateKey = self.heartRateKey.reverse()
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
