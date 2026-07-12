// Conversion factors are relative to a base unit per category (meter, gram).
// Temperature is handled separately since it isn't a simple linear scale factor.

export const LENGTH_TO_METERS = {
  km: 1000,
  m: 1,
  cm: 0.01,
  mm: 0.001,
  mi: 1609.344,
  yd: 0.9144,
  ft: 0.3048,
  in: 0.0254,
};

export const MASS_TO_GRAMS = {
  kg: 1000,
  g: 1,
  mg: 0.001,
  lb: 453.59237,
  oz: 28.349523125,
};

export const TEMPERATURE_UNITS = new Set(["c", "f", "k"]);

export function categoryOf(unit) {
  if (unit in LENGTH_TO_METERS) return "length";
  if (unit in MASS_TO_GRAMS) return "mass";
  if (TEMPERATURE_UNITS.has(unit)) return "temperature";
  return null;
}

export function listUnits() {
  return {
    length: Object.keys(LENGTH_TO_METERS),
    mass: Object.keys(MASS_TO_GRAMS),
    temperature: [...TEMPERATURE_UNITS],
  };
}
