import { LENGTH_TO_METERS, MASS_TO_GRAMS, categoryOf } from "./units.js";

export class ConversionError extends Error {}

function toCelsius(value, unit) {
  switch (unit) {
    case "c":
      return value;
    case "f":
      return ((value - 32) * 5) / 9;
    case "k":
      return value - 273.15;
  }
}

function fromCelsius(value, unit) {
  switch (unit) {
    case "c":
      return value;
    case "f":
      return (value * 9) / 5 + 32;
    case "k":
      return value + 273.15;
  }
}

function convertTemperature(value, from, to) {
  return fromCelsius(toCelsius(value, from), to);
}

function convertLinear(value, from, to, table) {
  return (value * table[from]) / table[to];
}

export function convert(value, fromUnit, toUnit) {
  const from = fromUnit.toLowerCase();
  const to = toUnit.toLowerCase();

  const fromCategory = categoryOf(from);
  const toCategory = categoryOf(to);

  if (!fromCategory) {
    throw new ConversionError(
      `unknown unit "${fromUnit}". Run 'conv --list' to see supported units.`
    );
  }
  if (!toCategory) {
    throw new ConversionError(
      `unknown unit "${toUnit}". Run 'conv --list' to see supported units.`
    );
  }
  if (fromCategory !== toCategory) {
    throw new ConversionError(
      `cannot convert ${fromCategory} (${from}) to ${toCategory} (${to})`
    );
  }

  if (fromCategory === "temperature") {
    return convertTemperature(value, from, to);
  }
  if (fromCategory === "length") {
    return convertLinear(value, from, to, LENGTH_TO_METERS);
  }
  return convertLinear(value, from, to, MASS_TO_GRAMS);
}
