<script>
const axios = require("axios");
import { Line, mixins } from 'vue-chartjs'
const { reactiveProp } = mixins

export default{
    name: 'LineChart',
    mixins: [reactiveProp],
    props: ['options'],
    extends: Line,
    mounted() {
        this.renderChartBar()
    },
    computed: {
        chartDataComputed() {
            return this.chartData 
        }
    },
    methods: {
        renderChartBar(){
            this.renderChart(this.chartDataComputed, this.options)
        }
    },
}
</script>