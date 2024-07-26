import React, {useEffect, useState} from "react";
import {
    ComposableMap,
    Geographies,
    Geography,
    Marker,
} from "react-simple-maps";
import Slider from "./Slider";
import {Container, Stack, Typography} from "@mui/material";
import visitorData from './national_parks_visitation2.json';
import BarChart from "./BarChart";
import Box from "@mui/material/Box";


const geoUrl = "https://cdn.jsdelivr.net/npm/us-atlas@3/states-10m.json";

const initialParks = [
    {markerOffset: -10, name: "Yellowstone", coordinates: [-110.5885, 44.4280], visitor: 0},
    {markerOffset: -10, name: "Yosemite", coordinates: [-119.5383, 37.8651], visitor: 0},
    {markerOffset: -10, name: "Grand Canyon", coordinates: [-112.1401, 35.0544], visitor: 0},
    {markerOffset: -10, name: "Zion", coordinates: [-113.0263, 37.2982], visitor: 0},
    {markerOffset: -10, name: "Acadia", coordinates: [-68.2098, 44.3386], visitor: 0},
    {markerOffset: -10, name: "Glacier", coordinates: [-113.8140, 48.7596], visitor: 0},
    {markerOffset: -10, name: "Great Smoky Mountains", coordinates: [-83.5070, 35.6118], visitor: 0},
    {markerOffset: -10, name: "Rocky Mountain", coordinates: [-105.6882, 40.3428], visitor: 0}
];


const MapChart = () => {

    const getRadius = (visitorCount) => {
        const minVisitors = 1814;
        const maxVisitors = 5967997;
        const minRadius = 2;
        const maxRadius = 20;
        if (visitorCount === 0) return minRadius; // If no visitors, return minimum radius
        const scale = (visitorCount - minVisitors) / (maxVisitors - minVisitors);
        return minRadius + (maxRadius - minRadius) * scale;
    };
    const [year, setYear] = useState(1904);
    const [nationalParks, setNationalParks] = useState(initialParks);

    useEffect(() => {
        const updatedParks = nationalParks.map(park => {
            const yearData = visitorData[year.toString()]?.find(p => p.name === park.name);
            return {...park, visitor: yearData ? yearData.visitors : 0};
        });
        setNationalParks(updatedParks);
    }, [year]);

    const [hoveredPark, setHoveredPark] = useState(null);
    const handleMouseEnter = (name) => {
        setHoveredPark(name);
    };

    const handleMouseLeave = () => {
        setHoveredPark(null);
    };

    return (
        <Box sx={{width: '100%', textAlign: 'center'}}>
            <Typography variant="h4" sx={{mb: 2}}>National Park Visitors</Typography>
            <Box sx={{maxWidth: 300, margin: 'auto', mb: 4}}>
                <Slider setYear={setYear}/>
            </Box>
            <Stack direction={'row'}>
                <Container sx={{width: '50%', height: 'auto'}}>

                    <ComposableMap projection="geoAlbersUsa">
                        <Geographies geography={geoUrl}>
                            {({geographies, outline, borders}) => (
                                <>
                                    <Geography geography={outline} fill="#E9E3DA"/>
                                    <Geography geography={borders} fill="none" stroke="#FFF"/>
                                </>
                            )}
                        </Geographies>
                        {nationalParks.map(({name, coordinates, visitor}) => (
                            <Marker key={name} coordinates={coordinates}
                                    onMouseEnter={() => handleMouseEnter(name)}
                                    onMouseLeave={handleMouseLeave}
                            >
                                <circle r={getRadius(visitor)}
                                        fill={hoveredPark === name ? "rgba(49,130,206,0.56)" : "rgba(228,42,29,0.6)"}
                                        stroke="#fff"
                                        strokeWidth={2}/>
                                <text
                                    textAnchor="middle"
                                    y={-25}
                                    style={{
                                        fontFamily: "system-ui",
                                        fill: "#5D5A6D",
                                        fontSize: "10px",
                                        pointerEvents: "none",
                                        paddingBottom: 5,
                                        fontWeight: 'bold'
                                    }}
                                >
                                    {name}
                                </text>
                                {hoveredPark === name && (
                                    <text
                                        textAnchor="middle"
                                        y={-15}
                                        style={{
                                            fontFamily: "system-ui",
                                            fill: "#5D5A6D",
                                            fontSize: "10px",
                                            pointerEvents: "none",
                                            fontWeight: 'bold'
                                        }}
                                    >
                                        ({visitor.toLocaleString()})
                                    </text>
                                )}
                            </Marker>
                        ))}
                    </ComposableMap>
                </Container>
                <Container sx={{width: '50%', height: 'auto'}}>
                    <BarChart data={visitorData} year={year}/>
                </Container>
            </Stack>
        </Box>
    );
};

export default MapChart;
