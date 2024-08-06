import React, { useEffect, useRef, useState } from "react";
import {Typography, Box, Stack, Container} from "@mui/material";
import * as d3 from "d3";
import visitorData from './national_parks_visitation2.json';
import { geoAlbersUsa, geoPath } from "d3-geo";
import { feature } from "topojson-client";
import Slider from "./Slider";
import BarChart from "./BarChart";

const initialParks = [
    { name: "Yellowstone", coordinates: [-110.5885, 44.4280], visitor: 0 },
    { name: "Yosemite", coordinates: [-119.5383, 37.8651], visitor: 0 },
    { name: "Grand Canyon", coordinates: [-112.1401, 35.0544], visitor: 0 },
    { name: "Zion", coordinates: [-113.0263, 37.2982], visitor: 0 },
    { name: "Acadia", coordinates: [-68.2098, 44.3386], visitor: 0 },
    { name: "Glacier", coordinates: [-113.8140, 48.7596], visitor: 0 },
    { name: "Great Smoky Mountains", coordinates: [-83.5070, 35.6118], visitor: 0 },
    { name: "Rocky Mountain", coordinates: [-105.6882, 40.3428], visitor: 0 }
];

const D3Chart = () => {
    const svgRef = useRef();
    const [year, setYear] = useState(1904);
    const [nationalParks, setNationalParks] = useState([]);

    useEffect(() => {
        fetch("https://cdn.jsdelivr.net/npm/us-atlas@3/states-10m.json")
            .then(response => response.json())
            .then(data => {
                const states = feature(data, data.objects.states);
                const projection = geoAlbersUsa().fitSize([800, 450], states);
                const svg = d3.select(svgRef.current);
                svg.selectAll(".state")
                    .data(states.features)
                    .join("path")
                    .attr("class", "state")
                    .attr("d", geoPath().projection(projection))
                    .attr("fill", "#E9E3DA");

                const markersGroup = svg.append("g").attr("class", "markers-group");

                // Transform initial parks data with projected coordinates
                const transformedParks = initialParks.map(park => ({
                    ...park,
                    coordinates: projection(park.coordinates),
                    visitor: 0
                })).filter(p => p.coordinates);

                setNationalParks(transformedParks);
            });

    }, []);

    useEffect(() => {
        if (nationalParks.length > 0) {
            const updatedParks = nationalParks.map(park => {
                const parkData = visitorData[year.toString()]?.find(p => p.name === park.name);
                return {
                    ...park,
                    visitor: parkData ? parkData.visitors : 0
                };
            });
            setNationalParks(updatedParks);
        }
    }, [year]);

    const getRadius = (visitorCount) => {
        const minVisitors = 1814;
        const maxVisitors = 5967997;
        const minRadius = 2;
        const maxRadius = 20;
        return visitorCount === 0 ? minRadius : minRadius + (maxRadius - minRadius) * ((visitorCount - minVisitors) / (maxVisitors - minVisitors));
    };

    useEffect(() => {
        const svg = d3.select(svgRef.current).select(".markers-group");

        svg.selectAll(".marker")
            .data(nationalParks)
            .join("circle")
            .attr("class", "marker")
            .attr("cx", d => d.coordinates[0])
            .attr("cy", d => d.coordinates[1])
            .attr("r", d => getRadius(d.visitor))
            .attr("fill", "red");

        svg.selectAll(".park-name")
            .data(nationalParks)
            .join("text")
            .attr("class", "park-name")
            .attr("x", d => d.coordinates[0])
            .attr("y", d => d.coordinates[1] - 10) 
            .text(d => d.name)
            .attr("text-anchor", "middle") 
            .style("font-size", "16px")
            .style("font-family", "Arial, sans-serif")
            .style("fill", "#333333");

    }, [nationalParks]);

    return (
        <Box sx={{width: '100%', textAlign: 'center'}}>
            <Typography variant="h4" sx={{mb: 2}}>National Park Visitors</Typography>
            <Box sx={{maxWidth: 300, margin: 'auto', mb: 4}}>
                <Slider setYear={setYear}/>
            </Box>
            <Stack direction={'row'}>
                <Container sx={{width: '50%', height: 'auto'}}>
                    <svg ref={svgRef} width="800" height="450" style={{border: "1px solid black"}}></svg>
                </Container>
                <Container sx={{width: '50%', height: 'auto'}}>
                    <BarChart data={visitorData} year={year}/>
                </Container>
            </Stack>

        </Box>
    );
};

export default D3Chart;
