import React, {useEffect, useRef} from 'react';
import * as d3 from 'd3';

const BarChart = ({data, year}) => {
    const ref = useRef();
    //Update chart when year changes
    useEffect(() => {
        if (data[year]) {
            const visitorsData = data[year].slice().sort((a, b) => a.visitors - b.visitors);

            const svg = d3.select(ref.current);
            svg.selectAll("*").remove();

            const margin = {top: 20, right: 30, bottom: 40, left: 90};
            const width = 500 - margin.left - margin.right;
            const height = 300 - margin.top - margin.bottom;

            const x = d3.scaleLinear()
                .domain([0, d3.max(visitorsData, d => d.visitors)])
                .range([0, width]);

            const y = d3.scaleBand()
                .domain(visitorsData.map(d => d.name))
                .range([0, height])
                .padding(0.1);

            const g = svg.append("g")
                .attr("transform", `translate(${margin.left},${margin.top})`);

            g.append("g")
                .call(d3.axisLeft(y));

            g.append("g")
                .attr("transform", `translate(0, ${height})`)
                .call(d3.axisBottom(x))
                .append("text")
                .attr("y", margin.bottom - 10)
                .attr("x", width)
                .attr("text-anchor", "end")
                .attr("stroke", "black")
                .text("Visitors");

            g.selectAll(".bar")
                .data(visitorsData)
                .enter().append("rect")
                .attr("class", "bar")
                .attr("y", d => y(d.name))
                .attr("height", y.bandwidth())
                .attr("x", 0)
                .attr("width", d => x(d.visitors))
                .attr("fill", "#69b3a2");
        }
    }, [data, year]);

    return (
        <div>
            <svg ref={ref} width={500} height={300}/>
        </div>
    );
};

export default BarChart;
