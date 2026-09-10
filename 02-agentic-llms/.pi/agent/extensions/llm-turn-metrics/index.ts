import { estimateTokens, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";

import { formatStatus, TurnMetricsTracker } from "./metrics.ts";

const STATUS_KEY = "llm-turn-metrics";
const REFRESH_INTERVAL_MS = 500;

export default function llmTurnMetrics(pi: ExtensionAPI): void {
	const tracker = new TurnMetricsTracker();
	let refreshTimer: ReturnType<typeof setInterval> | undefined;

	const renderSnapshot = (ctx: ExtensionContext, snapshot = tracker.snapshot(performance.now())) => {
		if (!snapshot) return;
		ctx.ui.setStatus(STATUS_KEY, ctx.ui.theme.fg("dim", formatStatus(snapshot)));
	};

	const stopRefresh = () => {
		if (refreshTimer === undefined) return;
		clearInterval(refreshTimer);
		refreshTimer = undefined;
	};

	const ensureStarted = (ctx: ExtensionContext) => {
		if (!tracker.start(performance.now())) return;
		renderSnapshot(ctx);
		refreshTimer = setInterval(() => renderSnapshot(ctx), REFRESH_INTERVAL_MS);
	};

	pi.on("before_agent_start", (_event, ctx) => {
		ensureStarted(ctx);
	});

	pi.on("agent_start", (_event, ctx) => {
		ensureStarted(ctx);
	});

	pi.on("message_update", (event) => {
		if (!tracker.active || event.message.role !== "assistant") return;
		tracker.updateCurrentEstimate(estimateTokens(event.message));
	});

	pi.on("message_end", (event, ctx) => {
		if (!tracker.active || event.message.role !== "assistant") return;
		tracker.completeAssistant(event.message.usage.output);
		renderSnapshot(ctx);
	});

	pi.on("agent_settled", (_event, ctx) => {
		const snapshot = tracker.settle(performance.now());
		stopRefresh();
		renderSnapshot(ctx, snapshot);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		stopRefresh();
		tracker.reset();
		ctx.ui.setStatus(STATUS_KEY, undefined);
	});
}
