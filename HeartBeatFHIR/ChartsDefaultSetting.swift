//
//  ChartDefaultSetting.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 26..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import SwiftCharts

struct ChartsDefaultSetting {
    static var chartSetting: ChartSettings {
        return self.iPhoneChartSettings
    }
    
    private static var iPhoneChartSettings: ChartSettings {
        let chartSettings = ChartSettings()
        chartSettings.leading = 0
        //chartSettings.leading
        chartSettings.top = 15
        chartSettings.trailing = 0
        chartSettings.bottom = 0
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        return chartSettings
    }
    
    static func chartFrame(containerBounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: (containerBounds.size.width), height: (containerBounds.size.height))
    }
    
    static func fontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Apple SD Gothic Neo", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: ChartsDefaultSetting.labelFont)
    }
    
    static var labelFont: UIFont {
        return ChartsDefaultSetting.fontWithSize(size: 11)
    }
    
    static var guidelinesWidth: CGFloat {
        return 0.1
    }
    
    static var minBarSpacing: CGFloat {
        return 5
    }
}
