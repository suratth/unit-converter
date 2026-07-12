import { test } from "node:test";
import assert from "node:assert/strict";
import { convert, ConversionError } from "../src/convert.js";

test("length: km to mi", () => {
  assert.ok(Math.abs(convert(100, "km", "mi") - 62.137119) < 1e-4);
});

test("length: m to cm", () => {
  assert.equal(convert(1, "m", "cm"), 100);
});

test("length: case-insensitive units", () => {
  assert.equal(convert(1, "KM", "M"), 1000);
});

test("mass: kg to lb", () => {
  assert.ok(Math.abs(convert(5, "kg", "lb") - 11.023113) < 1e-4);
});

test("mass: g to mg", () => {
  assert.equal(convert(1, "g", "mg"), 1000);
});

test("temperature: f to c", () => {
  assert.equal(convert(32, "f", "c"), 0);
});

test("temperature: c to k", () => {
  assert.equal(convert(0, "c", "k"), 273.15);
});

test("temperature: c to f", () => {
  assert.equal(convert(100, "c", "f"), 212);
});

test("same unit conversion returns same value", () => {
  assert.equal(convert(42, "km", "km"), 42);
});

test("throws on unknown source unit", () => {
  assert.throws(() => convert(1, "xx", "km"), ConversionError);
});

test("throws on unknown target unit", () => {
  assert.throws(() => convert(1, "km", "xx"), ConversionError);
});

test("throws on mismatched categories", () => {
  assert.throws(() => convert(1, "km", "kg"), ConversionError);
});
