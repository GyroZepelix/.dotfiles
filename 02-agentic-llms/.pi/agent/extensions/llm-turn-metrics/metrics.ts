export interface MetricsSnapshot {
	active: boolean;
	durationMs: number;
	outputTokens: number;
	tokensPerSecond: number;
	approximate: boolean;
}

export class TurnMetricsTracker {
	private startedAt: number | undefined;
	private completedOutputTokens = 0;
	private currentEstimatedOutputTokens = 0;
	private authoritative = true;
	private lastSettled: MetricsSnapshot | undefined;

	get active(): boolean {
		return this.startedAt !== undefined;
	}

	start(now: number): boolean {
		if (this.active) return false;

		this.startedAt = now;
		this.completedOutputTokens = 0;
		this.currentEstimatedOutputTokens = 0;
		this.authoritative = true;
		return true;
	}

	updateCurrentEstimate(tokens: number): void {
		if (!this.active) return;
		this.currentEstimatedOutputTokens = normalizeCount(tokens);
	}

	completeAssistant(outputTokens: number | undefined): void {
		if (!this.active) return;

		const reported = normalizeReportedCount(outputTokens);
		if (reported !== undefined && (reported > 0 || this.currentEstimatedOutputTokens === 0)) {
			this.completedOutputTokens += reported;
		} else if (this.currentEstimatedOutputTokens > 0) {
			this.completedOutputTokens += this.currentEstimatedOutputTokens;
			this.authoritative = false;
		} else if (reported !== undefined) {
			this.completedOutputTokens += reported;
		} else {
			this.authoritative = false;
		}

		this.currentEstimatedOutputTokens = 0;
	}

	snapshot(now: number): MetricsSnapshot | undefined {
		if (!this.active) return this.lastSettled;
		return createSnapshot(
			true,
			elapsedSince(this.startedAt!, now),
			this.completedOutputTokens + this.currentEstimatedOutputTokens,
			true,
		);
	}

	settle(now: number): MetricsSnapshot | undefined {
		if (!this.active) return this.lastSettled;

		if (this.currentEstimatedOutputTokens > 0) {
			this.completedOutputTokens += this.currentEstimatedOutputTokens;
			this.currentEstimatedOutputTokens = 0;
			this.authoritative = false;
		}

		this.lastSettled = createSnapshot(
			false,
			elapsedSince(this.startedAt!, now),
			this.completedOutputTokens,
			!this.authoritative,
		);
		this.startedAt = undefined;
		return this.lastSettled;
	}

	reset(): void {
		this.startedAt = undefined;
		this.completedOutputTokens = 0;
		this.currentEstimatedOutputTokens = 0;
		this.authoritative = true;
		this.lastSettled = undefined;
	}
}

function normalizeCount(value: number): number {
	return Number.isFinite(value) && value > 0 ? value : 0;
}

function normalizeReportedCount(value: number | undefined): number | undefined {
	return typeof value === "number" && Number.isFinite(value) && value >= 0 ? value : undefined;
}

function elapsedSince(startedAt: number, now: number): number {
	return Number.isFinite(now) ? Math.max(0, now - startedAt) : 0;
}

function createSnapshot(
	active: boolean,
	durationMs: number,
	outputTokens: number,
	approximate: boolean,
): MetricsSnapshot {
	const tokensPerSecond = durationMs > 0 ? outputTokens / (durationMs / 1000) : 0;
	return {
		active,
		durationMs,
		outputTokens,
		tokensPerSecond: Number.isFinite(tokensPerSecond) ? tokensPerSecond : 0,
		approximate,
	};
}

export function formatDuration(durationMs: number): string {
	const seconds = Math.max(0, Number.isFinite(durationMs) ? durationMs : 0) / 1000;
	if (seconds < 60) return `${seconds.toFixed(1)}s`;

	const roundedSeconds = Math.round(seconds);
	if (roundedSeconds < 3600) {
		const minutes = Math.floor(roundedSeconds / 60);
		const remainingSeconds = roundedSeconds % 60;
		return `${minutes}m ${remainingSeconds.toString().padStart(2, "0")}s`;
	}

	const roundedMinutes = Math.round(seconds / 60);
	const hours = Math.floor(roundedMinutes / 60);
	const remainingMinutes = roundedMinutes % 60;
	return `${hours}h ${remainingMinutes.toString().padStart(2, "0")}m`;
}

export function formatStatus(snapshot: MetricsSnapshot): string {
	const rate = Math.max(0, snapshot.tokensPerSecond).toFixed(1);
	const approximation = snapshot.approximate ? "~" : "";
	return `LLM ${formatDuration(snapshot.durationMs)} ${approximation}${rate} t/s`;
}
