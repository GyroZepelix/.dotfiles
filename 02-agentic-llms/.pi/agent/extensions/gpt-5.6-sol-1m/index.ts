import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const ALIAS_MODEL_ID = "gpt-5.6-sol-1m";
const UPSTREAM_MODEL_ID = "gpt-5.6-sol";

export function rewriteAliasModel(payload: unknown): unknown | undefined {
	if (payload === null || typeof payload !== "object" || Array.isArray(payload)) return undefined;
	if (!("model" in payload) || payload.model !== ALIAS_MODEL_ID) return undefined;

	return { ...payload, model: UPSTREAM_MODEL_ID };
}

export default function gpt56Sol1mAlias(pi: ExtensionAPI): void {
	pi.on("before_provider_request", (event) => rewriteAliasModel(event.payload));
}
