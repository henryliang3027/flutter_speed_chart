# Flutter Speed Chart

這個套件是專為繪製大量數據點而設計的 Flutter 折線圖圖表元件，能在一個圖表中呈現 40000 筆數據，同時維持流暢的操作體驗和渲染效能。

## 特色功能

### 圖表渲染

- **多系列支援**：可在同一個圖表上比較不同的數據，添加多條線，每條線都有自己的顏色和名稱
- **智慧軸線**：可不用設定 X、Y 軸的範圍，圖表會根據數據自動調整到最佳顯示範圍
- **圖例功能**：圖例會標示每條線的名稱和顏色，可選擇顯示或隱藏

### 手勢操作支援

- **縮放功能**：大量數據點顯示在螢幕上不容易看，可用兩隻手指捏合就能放大縮小圖表
- **平移操作**：放大後的圖表在螢幕上看不完，用一隻手指拖拽就能左右平移圖表，輕鬆瀏覽所有數據
- **數據點資訊**：想知道某個點的確切數值，長按圖表就會顯示懸浮視窗，提示該位置所有系列的詳細數值
- **範圍拖曳條**：圖表上方的 Widget，你可以拖拽兩端來快速選擇想要查看的數據範圍，拖曳中間橫條可以左右平移圖表，可選擇顯示或隱藏，建議使用於桌面應用(Windows, MacOS, Linux) 或 Web 並用滑鼠控制


## 快速開始

### 1. 安裝套件

在您的 Flutter 專案中的 `pubspec.yaml` 檔案中添加：

方法一：使用 Git Repository
```yaml
dependencies:
  flutter_speed_chart:
    git:
      url: https://github.com/your-repo/flutter_speed_chart.git # git repository 路徑
      ref: master
```

方法二：使用本地端路徑
```yaml
dependencies:
  flutter_speed_chart:
    path: /path/to/flutter_speed_chart # 本地端路徑
```

然後執行：
```bash
flutter pub get
```

### 2. 基本使用示例

```dart
import 'package:flutter_speed_chart/speed_chart.dart';
import 'package:flutter/material.dart';

class MyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 準備數據
    final List<ValuePair> data = [
      ValuePair(x: 261, y: 35.0),
      ValuePair(x: 267, y: 35.1),
      ValuePair(x: 273, y: 35.2),
      ValuePair(x: 279, y: 35.1),
      ValuePair(x: 285, y: 35.3),
    ];

    List<LineSeries> lineSeriesCollection1 = [LineSeries(
      name: '數據1',
      color: Colors.blue,
      dataList: data,
    )];

    return Scaffold(
      appBar: AppBar(title: Text('Speed Chart Example')),
      body: Center(
        child: Container(
          height: 300,
          child: SpeedLineChart(
            lineSeriesCollection: lineSeriesCollection1,
            showLegend: true,
          ),
        ),
      ),
    );
  }
}
```

完整使用範例請參考：`example/lib/main.dart`

## API 函數說明

### SpeedLineChart 類別

#### 建構函數

**`SpeedLineChart({required List<LineSeries> lineSeriesCollection, String title = '', bool showLegend = true, bool showMultipleYAxises = false, bool showScaleThumbs = false, String xAxisUnit = ''})`**

- **功能**：創建一個高效能的線性圖表組件，適合處理大量數據點
- **參數**：
  - `lineSeriesCollection` (List<LineSeries>, required) - 圖表的數據系列列表，每個 LineSeries 代表一條線
  - `title` (String, optional) - 圖表頂部顯示的標題，預設為空字串
  - `showLegend` (bool, optional) - 是否顯示圖例，圖例會顯示每個系列的名稱和顏色，預設為 true
  - `showMultipleYAxises` (bool, optional) - 是否顯示多個 Y 軸，當想要顯示多組相同 X 軸單位，不同 Y 軸單位的數據系列時使用，預設為 false
  - `showScaleThumbs` (bool, optional) - 是否啟用範圍拖拽條，預設為 false
  - `xAxisUnit` (String, optional) - 適用於 int 格式的 X 軸的單位，DateTime 格式不適用，會顯示在懸浮視窗提示中，預設為空字串，可設定任意字串，例如：MHz

### LineSeries 類別

#### 建構函數

**`LineSeries({required String name, required List<ValuePair> dataList, required Color color, double? maxYAxisValue, double? minYAxisValue})`**

- **功能**：表示圖表中的一個數據系列，包含該系列的所有配置和數據點
- **參數**：
  - `name` (String, required) - 系列的顯示名稱，會顯示在圖例和懸浮視窗提示中
  - `dataList` (List<ValuePair>, required) - 該系列的所有數據點列表
  - `color` (Color, required) - 線條的顏色，決定該系列在圖表上的視覺外觀
  - `maxYAxisValue` (double?, optional) - 該系列 Y 軸的最大值，如果不提供則由圖表自動計算最大值
  - `minYAxisValue` (double?, optional) - 該系列 Y 軸的最小值，如果不提供則由圖表自動計算最小值

### ValuePair 類別

#### 建構函數

**`ValuePair({required T x, required double? y})`**

- **功能**：表示圖表中一個數據系列的單一數據點，包含 X 和 Y 座標值
- **參數**：
  - `x` (T, required) - X 軸的值，支援格式有 DateTime、int
  - `y` (double?, required) - Y 軸的值，可為 null，null 值不會在圖表上顯示



## 平台支援

支援所有 Flutter 平台：
- **Android**
- **iOS**
- **Web**
- **Windows**
- **macOS**
- **Linux**
