import { Controller } from "@hotwired/stimulus"
import { Chart, RadarController, RadialLinearScale, PointElement, LineElement, Filler, Tooltip, Legend } from "chart.js"

Chart.register(RadarController, RadialLinearScale, PointElement, LineElement, Filler, Tooltip, Legend)

export default class extends Controller {
  static targets = ["canvas"]

  static RATING_ITEMS = [
    { label: "テンポ", field: "tempo" },
    { label: "運指技巧", field: "fingering" },
    { label: "弾弦技巧", field: "plucking" },
    { label: "表現力", field: "expression" },
    { label: "暗譜・構成理解", field: "memorization" }
  ]

  connect() {
    if (!this.hasCanvasTarget) return
    this.initializeChart()
  }

  disconnect() {
    this.chart?.destroy()
  }

  initializeChart() {
    const canvas = this.canvasTarget
    const ctx = canvas.getContext("2d")
    const ratings = this.constructor.RATING_ITEMS.map(item =>
      this.ratingValue(canvas.dataset[item.field])
    )

    this.chart = new Chart(ctx, {
      type: "radar",
      data: {
        labels: this.constructor.RATING_ITEMS.map(item => item.label),
        datasets: [
          {
            label: "評価",
            data: ratings,
            fill: true,
            backgroundColor: "rgba(92, 64, 51, 0.2)",
            borderColor: "rgba(92, 64, 51, 1)",
            pointRadius: 0,
            pointHoverRadius: 0
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 1,
        animation: false,
        scales: {
          r: {
            angleLines: {
              display: true,
              color: "rgba(0, 0, 0, 0.1)"
            },
            suggestedMin: 0,
            suggestedMax: 5,
            ticks: {
              stepSize: 1,
              display: true,
              backdropColor: "transparent",
              font: {
                size: 10
              }
            },
            pointLabels: {
              display: false
            },
            grid: {
              color: "rgba(0, 0, 0, 0.1)"
            }
          }
        },
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            enabled: true
          }
        }
      }
    })
  }

  ratingValue(rawValue) {
    const parsed = parseInt(rawValue, 10)
    return Number.isNaN(parsed) ? 0 : parsed
  }
}
