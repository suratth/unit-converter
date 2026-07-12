#!/usr/bin/env node
import { convert, ConversionError } from "../src/convert.js";
import { listUnits } from "../src/units.js";

const USAGE = `Usage: conv <value> <from> <to>

Examples:
  conv 100 km mi
  conv 32 f c
  conv 5 kg lb

Options:
  -l, --list              List supported units by category
  -h, --help               Show this help message
      --precision <n>      Number of decimal places in the output (default: 4)`;

function printUnitList() {
  const units = listUnits();
  for (const [category, list] of Object.entries(units)) {
    console.log(`${category}: ${list.join(", ")}`);
  }
}

function formatNumber(value, precision) {
  const fixed = value.toFixed(precision);
  return fixed.includes(".")
    ? fixed.replace(/0+$/, "").replace(/\.$/, "")
    : fixed;
}

function parseArgs(argv) {
  const positional = [];
  let precision = 4;

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--precision") {
      const next = argv[++i];
      precision = Number(next);
      if (!Number.isInteger(precision) || precision < 0) {
        throw new ConversionError(`invalid --precision value "${next}"`);
      }
    } else if (arg.startsWith("--precision=")) {
      const next = arg.slice("--precision=".length);
      precision = Number(next);
      if (!Number.isInteger(precision) || precision < 0) {
        throw new ConversionError(`invalid --precision value "${next}"`);
      }
    } else {
      positional.push(arg);
    }
  }

  return { positional, precision };
}

function main() {
  const argv = process.argv.slice(2);

  if (argv.length === 0) {
    console.error(USAGE);
    process.exit(1);
  }

  if (argv.includes("-h") || argv.includes("--help")) {
    console.log(USAGE);
    process.exit(0);
  }

  if (argv.includes("-l") || argv.includes("--list")) {
    printUnitList();
    process.exit(0);
  }

  const { positional, precision } = parseArgs(argv);

  if (positional.length !== 3) {
    console.error(`Error: expected 3 arguments, got ${positional.length}\n`);
    console.error(USAGE);
    process.exit(1);
  }

  const [rawValue, from, to] = positional;
  const value = Number(rawValue);
  if (Number.isNaN(value)) {
    console.error(`Error: "${rawValue}" is not a valid number`);
    process.exit(1);
  }

  const result = convert(value, from, to);
  console.log(formatNumber(result, precision));
}

try {
  main();
} catch (err) {
  if (err instanceof ConversionError) {
    console.error(`Error: ${err.message}`);
    process.exit(1);
  }
  throw err;
}
