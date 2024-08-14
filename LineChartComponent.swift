
import SwiftUI
import UIComponents


public struct LineChartData {
    public let yValue: Double // 23.4 C, 25.0 C
    public let yPointValue: String // 23.4 C, 25.0 C
    public let xValue: String // Jan, Feb
    
    public init(
        xValue: String,
        yValue: Double,
        yPointValue: String
    ) {
        self.yValue = yValue
        self.yPointValue = yPointValue
        self.xValue = xValue
    }
}

public struct LineChartUIModel {
    let imageHeader: Image?
    let imageBackgroundColor: Color?
    let titleHeader: String?
    let timePeriod: String?
    var ratedTempArray: [Double] = []
    let lineChartData: [LineChartData]
    
    public init(
        imageHeader: Image? = nil,
        imageBackgroundColor: Color? = Color.red,
        timePeriod: String? = "",
        titleHeader: String? = nil,
        lineChartData: [LineChartData]
    ) {
        self.imageHeader = imageHeader
        self.imageBackgroundColor = imageBackgroundColor
        self.timePeriod = timePeriod
        self.titleHeader = titleHeader
        self.lineChartData = lineChartData
        self.ratedTempArray = self.convertRatedArray()
    }
    
    private func convertRatedArray() -> [Double] {
        var temperatures: [Double] = []
        for item in self.lineChartData {
            temperatures.append(item.yValue)
        }
        let averageTemperature = temperatures.reduce(0, +) / Double(temperatures.count)
        let maxDeviation = temperatures.reduce(0) { max($0, abs($1 - averageTemperature)) }
        let normalizedTemperatures = temperatures.map { temperature in
            return (temperature - averageTemperature + maxDeviation) / (6 * maxDeviation)
        }
        return normalizedTemperatures
    }
    
}

public struct LineChartComponent: View {
    let uiModel: LineChartUIModel
    let chartBackgroundGridHeight: CGFloat = 50
    let chartBackgroundGridWidth: CGFloat = 70
    
    public init(uiModel: LineChartUIModel) {
        self.uiModel = uiModel
    }

    public var body: some View {
        VStack {
            HStack(spacing: 0) {
                if let image = uiModel.imageHeader {
                    Circle()
                        .frame(width: 48, height: 48)
                        .overlay(
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                        )
                        .foregroundColor(uiModel.imageBackgroundColor)
                }
                if let title = uiModel.titleHeader {
                    Text(title)
                        .foregroundColor(Color.black)
                        .fontTemplate(Default.Regular.Footnote)
                        .padding(.leading, .paddingXs)
                    Spacer()
                    if let timePerioud = uiModel.timePeriod {
                        Text(timePerioud)
                            .foregroundColor(Color.colorTextTertiary)
                            .fontTemplate(Default.Regular.Caption2)
                    }
                }
            }
            .padding(.horizontal, .paddingMd)
            .padding(.vertical, .paddingXs)
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        let average: CGFloat =  uiModel.ratedTempArray.reduce(0, +) / Double(uiModel.ratedTempArray.count)
                        //GridView
                        ZStack {
                            ForEach(0..<uiModel.ratedTempArray.count-1) { i in
                                ForEach(0..<4) { j in
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 0.8)
                                        .frame(width: chartBackgroundGridWidth, height: chartBackgroundGridHeight)
                                        .position(x: CGFloat(i) * chartBackgroundGridWidth + chartBackgroundGridWidth / 2, y: CGFloat(j) * chartBackgroundGridHeight + chartBackgroundGridHeight / 2)
                                }
                            }
                            
                            // Line Chart
                            Path { path in
                                for i in 0..<uiModel.lineChartData.count {
                                    let x = 70 * CGFloat(i)
                                    if i == 0 {
                                        path.move(to: CGPoint(x: x, y: self.calculateDifferenceRatios(average: average, element: uiModel.ratedTempArray[i])))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: self.calculateDifferenceRatios(average: average, element: uiModel.ratedTempArray[i])))
                                    }
                                }
                            }
                            .stroke(Color.cyan, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .animation(.easeInOut(duration: 1.5))
                            
                            GeometryReader { geometry in
                                ForEach(0..<uiModel.ratedTempArray.count) { i in
                                    let x = chartBackgroundGridWidth * CGFloat(i)
                                    let y = self.calculateDifferenceRatios(average: average, element: uiModel.ratedTempArray[i])
                                    VStack {
                                        Text(String(uiModel.lineChartData[i].yPointValue))
                                            .foregroundColor(Color.black)
                                            .font(Font.footnote)
                                            .padding(.bottom, 2)
                                        Circle()
                                            .frame(width: 8, height: 8)
                                            .foregroundColor(Color.blue)
                                    }
                                    .position(x: x, y: y - 13)
                                    .animation(.easeIn, value: 2.0)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(0..<uiModel.lineChartData.count) { index in
                            Text(uiModel.lineChartData[index].xValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: chartBackgroundGridWidth,height: 20)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, -(chartBackgroundGridWidth / 2))
                }
                .padding(.horizontal, 20)
            }
        }
        .background(.white)
        .cornerRadius(12)
    }
    
    private func calculateDifferenceRatios(average: Double, element: Double) -> Double {
        let differenceRate: Double = 25.0
        let difference = abs(average - element)
        let ratio = difference / average
        return (average == element) ? 100.0 : (element > average ? 100 - ratio * differenceRate : 100 + ratio * differenceRate)
    }
}
