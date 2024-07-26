import * as React from 'react';
import Box from '@mui/material/Box';
import Slider from '@mui/material/Slider';
import { useState } from "react";
import {Typography} from "@mui/material";

const marks = [
  {
    value: 0,
    label: '1904',
  },
  {
    value: 100,
    label: '2016',
  },
];

export default function DiscreteSliderMarks({setYear}) {
  // Initialize sliderValue to 80, which corresponds to 1984
  const [sliderValue, setSliderValue] = useState(80);

  function valuetext(value) {
    return `${1904 + Math.round(value * 1.12)}`; // Converts slider value to the actual year
  }

  const handleChange = (event, newValue) => {
    setSliderValue(newValue); // Update the state with the new slider value
    setYear(1904 + Math.round(newValue * 1.12));
  };

  return (
    <Box sx={{ width: 300, paddingTop: 5 }}>
      <Typography sx={{textAlign:'center'}}>
        {valuetext(sliderValue)}
      </Typography>
      <Slider
        aria-label="Year selector"
        value={sliderValue} // Bind the slider value to the state
        onChange={handleChange} // Update the state when the slider changes
        getAriaValueText={valuetext} // Generate label text for the thumb
        step={1} // Use a step of 1 for finer granularity
        marks={marks}
      />
    </Box>
  );
}
