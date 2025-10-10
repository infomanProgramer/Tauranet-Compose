<script>
const axios = require("axios");
import { Bar, mixins } from 'vue-chartjs'
const { reactiveProp } = mixins

export default{
    name: 'BarChart',
    mixins: [reactiveProp],
    props: ['options'],
    extends: Bar,
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