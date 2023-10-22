//
//  CombinedTestViewController.swift
//  ChartsDemo-iOS-Swift
//
//  Created by Dmytro Barabash1 on 21.10.2023.
//  Copyright © 2023 dcg. All rights reserved.
//

import UIKit
import DGCharts

// Example how to face a crash.
// 1) add line & scatter charts on combine chart view
// 2) highlight scatter value on chart
// 3) add bar chart
// Result - crash
// Reason -> bar chart will have the same index as scatter had before and instead of highlighting scatter it tries to highlight bar chart

final class CombinedTestViewController: DemoBaseViewController {

    private let chartView: CombinedChartView = .init()
    private let sliderXValue = 45
    private let sliderYValue = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        addChartView()
        title = "Wait 4 sec for a crash"
        configChartView()
        updateChartData()
    }

    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }

        self.setDataCount(sliderXValue, range: UInt32(sliderYValue))
    }
}

private extension CombinedTestViewController {
    func setDataCount(_ count: Int, range: UInt32) {
        let combinedChartData = CombinedChartData()
        func setLineChartData() {
            let values = (0..<count).map { (i) -> ChartDataEntry in
                let val = Double(arc4random_uniform(range) + 3)
                return ChartDataEntry(x: Double(i), y: val, icon: #imageLiteral(resourceName: "icon"))
            }

            let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
            set1.drawIconsEnabled = false
            setup(set1)

            let value = ChartDataEntry(x: Double(3), y: 3)
            set1.addEntryOrdered(value)
            let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                                  ChartColorTemplates.colorFromString("#ffff0000").cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

            set1.fillAlpha = 1
            set1.fill = LinearGradientFill(gradient: gradient, angle: 90)
            set1.drawFilledEnabled = true
            
            combinedChartData.lineData = LineChartData(dataSet: set1)
        }
        
        func setBarChartData() {
            let start = 1
            let yVals = (start..<start+count+1).map { (i) -> BarChartDataEntry in
                let mult = range + 1
                let val = Double(arc4random_uniform(mult))
                if arc4random_uniform(100) < 25 {
                    return BarChartDataEntry(x: Double(i), y: val, icon: UIImage(named: "icon"))
                } else {
                    return BarChartDataEntry(x: Double(i), y: val)
                }
            }
            
            var set1: BarChartDataSet! = nil
            if let set = chartView.data?.first as? BarChartDataSet {
                set1 = set
                set1.replaceEntries(yVals)
                chartView.data?.notifyDataChanged()
                chartView.notifyDataSetChanged()
            } else {
                set1 = BarChartDataSet(entries: yVals, label: "The year 2017")
                set1.colors = ChartColorTemplates.material()
                set1.drawValuesEnabled = false
                
                let data = BarChartData(dataSet: set1)
                data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                data.barWidth = 0.9
                combinedChartData.barData = data
            }
        }
        
        func setScatter() {
            let values1 = (0..<count).map { (i) -> ChartDataEntry in
                let val = Double(arc4random_uniform(range) + 3)
                return ChartDataEntry(x: Double(i), y: val)
            }
            let values2 = (0..<count).map { (i) -> ChartDataEntry in
                let val = Double(arc4random_uniform(range) + 3)
                return ChartDataEntry(x: Double(i) + 0.33, y: val)
            }
            let values3 = (0..<count).map { (i) -> ChartDataEntry in
                let val = Double(arc4random_uniform(range) + 3)
                return ChartDataEntry(x: Double(i) + 0.66, y: val)
            }

            
            let set1 = ScatterChartDataSet(entries: values1, label: "DS 1")
            set1.setScatterShape(.square)
            set1.setColor(ChartColorTemplates.colorful()[0])
            set1.scatterShapeSize = 8
            
            let set2 = ScatterChartDataSet(entries: values2, label: "DS 2")
            set2.setScatterShape(.circle)
            set2.scatterShapeHoleColor = ChartColorTemplates.colorful()[3]
            set2.scatterShapeHoleRadius = 3.5
            set2.setColor(ChartColorTemplates.colorful()[1])
            set2.scatterShapeSize = 8
            
            let set3 = ScatterChartDataSet(entries: values3, label: "DS 3")
            set3.setScatterShape(.cross)
            set3.setColor(ChartColorTemplates.colorful()[2])
            set3.scatterShapeSize = 8
            
            let data: ScatterChartData = [set1, set2, set3]
            data.setValueFont(.systemFont(ofSize: 7, weight: .light))
            combinedChartData.scatterData = data
        }
        
        setLineChartData()
        // setBar()
        setScatter()
        chartView.data = combinedChartData
        
        let dataset = 2 // scatter number in this flow
        let dataSet = chartView.scatterData!.dataSets[dataset]
        let last = dataSet.entryForXValue(self.chartView.scatterData!.xMax, closestToY: .nan)!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            print("*** 1 sec delay passed ***")
            guard let self else { return }
            self.chartView.highlightValue(Highlight(x: last.x, y: last.y, dataSetIndex: dataset, dataIndex: 1), callDelegate: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            print(("*** 3 sec delay passed ***"))
            guard let self else { return }
            setBarChartData()
            self.chartView.data = combinedChartData
        }
    }

    private func setup(_ dataSet: LineChartDataSet) {
        if dataSet.isDrawLineWithGradientEnabled {
            dataSet.lineDashLengths = nil
            dataSet.highlightLineDashLengths = nil
            dataSet.setColors(.black, .red, .white)
            dataSet.setCircleColor(.black)
            dataSet.gradientPositions = [0, 40, 100]
            dataSet.lineWidth = 1
            dataSet.circleRadius = 3
            dataSet.drawCircleHoleEnabled = false
            dataSet.valueFont = .systemFont(ofSize: 9)
            dataSet.formLineDashLengths = nil
            dataSet.formLineWidth = 1
            dataSet.formSize = 15
        } else {
            dataSet.lineDashLengths = [5, 2.5]
            dataSet.highlightLineDashLengths = [5, 2.5]
            dataSet.setColor(.black)
            dataSet.setCircleColor(.black)
            dataSet.gradientPositions = nil
            dataSet.lineWidth = 1
            dataSet.circleRadius = 3
            dataSet.drawCircleHoleEnabled = false
            dataSet.valueFont = .systemFont(ofSize: 9)
            dataSet.formLineDashLengths = [5, 2.5]
            dataSet.formLineWidth = 1
            dataSet.formSize = 15
        }
    }
    
    func addChartView() {
        view.backgroundColor = .white
        view.addSubview(chartView)
        chartView.backgroundColor = .gray
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            chartView.topAnchor.constraint(equalTo: view.topAnchor),
            chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configChartView() {
        chartView.delegate = self
        chartView.chartDescription.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true

        // x-axis limit line
        let llXAxis = ChartLimitLine(limit: 10, label: "Index 10")
        llXAxis.lineWidth = 4
        llXAxis.lineDashLengths = [10, 10, 0]
        llXAxis.labelPosition = .rightBottom
        llXAxis.valueFont = .systemFont(ofSize: 10)

        chartView.xAxis.gridLineDashLengths = [10, 10]
        chartView.xAxis.gridLineDashPhase = 0

        let ll1 = ChartLimitLine(limit: 150, label: "Upper Limit")
        ll1.lineWidth = 4
        ll1.lineDashLengths = [5, 5]
        ll1.labelPosition = .rightTop
        ll1.valueFont = .systemFont(ofSize: 10)

        let ll2 = ChartLimitLine(limit: -30, label: "Lower Limit")
        ll2.lineWidth = 4
        ll2.lineDashLengths = [5,5]
        ll2.labelPosition = .rightBottom
        ll2.valueFont = .systemFont(ofSize: 10)

        let leftAxis = chartView.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(ll1)
        leftAxis.addLimitLine(ll2)
        leftAxis.axisMaximum = 200
        leftAxis.axisMinimum = -50
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true

        chartView.rightAxis.enabled = false

        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker

        chartView.legend.form = .line

        chartView.animate(xAxisDuration: 0.5)
    }
}
