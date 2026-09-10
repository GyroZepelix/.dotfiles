import { describe, expect, test } from "bun:test";

import { formatDuration, formatStatus, TurnMetricsTracker } from "./metrics.ts";

describe("TurnMetricsTracker", () => {
	test("keeps the first start time while a span is active", () => {
		const tracker = new TurnMetricsTracker();

		expect(tracker.start(1_000)).toBe(true);
		tracker.updateCurrentEstimate(20);
		expect(tracker.start(5_000)).toBe(false);

		expect(tracker.snapshot(6_000)).toEqual({
			active: true,
			durationMs: 5_000,
			outputTokens: 20,
			tokensPerSecond: 4,
			approximate: true,
		});
	});

	test("replaces cumulative live estimates instead of double-counting them", () => {
		const tracker = new TurnMetricsTracker();
		tracker.start(0);

		tracker.updateCurrentEstimate(100);
		tracker.updateCurrentEstimate(40);

		expect(tracker.snapshot(1_000)?.outputTokens).toBe(40);
	});

	test("aggregates authoritative output across assistant messages", () => {
		const tracker = new TurnMetricsTracker();
		tracker.start(0);

		tracker.updateCurrentEstimate(30);
		tracker.completeAssistant(25);
		tracker.updateCurrentEstimate(15);
		tracker.completeAssistant(20);

		const settled = tracker.settle(2_000);
		expect(settled).toEqual({
			active: false,
			durationMs: 2_000,
			outputTokens: 45,
			tokensPerSecond: 22.5,
			approximate: false,
		});
		expect(tracker.snapshot(20_000)).toEqual(settled);
	});

	test("retains an estimated fallback when final usage is unavailable", () => {
		const tracker = new TurnMetricsTracker();
		tracker.start(0);
		tracker.updateCurrentEstimate(12);
		tracker.completeAssistant(undefined);

		expect(tracker.settle(1_000)).toEqual({
			active: false,
			durationMs: 1_000,
			outputTokens: 12,
			tokensPerSecond: 12,
			approximate: true,
		});
	});

	test("treats zero reported usage with generated output as unavailable", () => {
		const tracker = new TurnMetricsTracker();
		tracker.start(0);
		tracker.updateCurrentEstimate(8);
		tracker.completeAssistant(0);

		const settled = tracker.settle(1_000);
		expect(settled?.outputTokens).toBe(8);
		expect(settled?.approximate).toBe(true);
	});

	test("settles an unfinished stream as approximate", () => {
		const tracker = new TurnMetricsTracker();
		tracker.start(100);
		tracker.updateCurrentEstimate(5);

		expect(tracker.settle(1_100)).toEqual({
			active: false,
			durationMs: 1_000,
			outputTokens: 5,
			tokensPerSecond: 5,
			approximate: true,
		});
	});

	test("guards negative elapsed time and invalid estimates", () => {
		const tracker = new TurnMetricsTracker();
		tracker.start(1_000);
		tracker.updateCurrentEstimate(Number.NaN);

		expect(tracker.snapshot(500)).toEqual({
			active: true,
			durationMs: 0,
			outputTokens: 0,
			tokensPerSecond: 0,
			approximate: true,
		});
	});

	test("reset removes active and retained state", () => {
		const tracker = new TurnMetricsTracker();
		tracker.start(0);
		tracker.completeAssistant(10);
		tracker.settle(1_000);
		tracker.reset();

		expect(tracker.active).toBe(false);
		expect(tracker.snapshot(2_000)).toBeUndefined();
	});
});

describe("formatting", () => {
	test("formats short, minute, and hour durations compactly", () => {
		expect(formatDuration(8_240)).toBe("8.2s");
		expect(formatDuration(68_000)).toBe("1m 08s");
		expect(formatDuration(3_900_000)).toBe("1h 05m");
	});

	test("marks approximate rates only when required", () => {
		expect(
			formatStatus({
				active: true,
				durationMs: 8_240,
				outputTokens: 347,
				tokensPerSecond: 42.111,
				approximate: true,
			}),
		).toBe("LLM 8.2s ~42.1 t/s");

		expect(
			formatStatus({
				active: false,
				durationMs: 12_740,
				outputTokens: 489,
				tokensPerSecond: 38.383,
				approximate: false,
			}),
		).toBe("LLM 12.7s 38.4 t/s");
	});
});
