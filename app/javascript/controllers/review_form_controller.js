import { Controller } from "@hotwired/stimulus"
import { Chart, RadarController, RadialLinearScale, PointElement, LineElement, Filler, Tooltip, Legend } from "chart.js"

Chart.register(RadarController, RadialLinearScale, PointElement, LineElement, Filler, Tooltip, Legend)

export default class extends Controller {
  static targets = ["chart"]

  static RATING_ITEMS = [
    { label: "テンポ", field: "tempo_rating" },
    { label: "運指技巧", field: "fingering_technique_rating" },
    { label: "弾弦技巧", field: "plucking_technique_rating" },
    { label: "表現力", field: "expression_rating" },
    { label: "暗譜・構成理解", field: "memorization_rating" }
  ]

  connect() {
    if (!this.hasChartTarget) return
    this.initializeChart()
    this.updateChart()
  }

  disconnect() {
    this.chart?.destroy()
  }

  initializeChart() {
    const ctx = this.chartTarget.getContext("2d")
    const initialData = Array(this.constructor.RATING_ITEMS.length).fill(0)

    this.chart = new Chart(ctx, {
      type: "radar",
      data: {
        labels: this.constructor.RATING_ITEMS.map(item => item.label),
        datasets: [{
          label: "評価",
          data: initialData,
          fill: true,
          backgroundColor: "rgba(92, 64, 51, 0.2)",
          borderColor: "rgba(92, 64, 51, 1)",
          pointBackgroundColor: "rgba(92, 64, 51, 1)",
          pointBorderColor: "#fff",
          pointHoverBackgroundColor: "#fff",
          pointHoverBorderColor: "rgba(92, 64, 51, 1)"
        }]
      },
      options: {
        responsive: true,
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
              backdropColor: "transparent"
            },
            pointLabels: {
              font: {
                size: 12,
                family: "'Noto Sans JP', sans-serif"
              }
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

  updatePreview() {
    this.updateChart()
  }

  updateChart() {
    const ratings = this.constructor.RATING_ITEMS.map(item =>
      this.getSelectedRating(item.field)
    )
    this.chart.data.datasets[0].data = ratings
    this.chart.update()
  }

  getSelectedRating(fieldName) {
    const input = this.element.querySelector(`input[name="review[${fieldName}]"]:checked`)
    return input ? parseInt(input.value) : 0
  }
}
