import { describe, expect, test } from "bun:test";

import { rewriteAliasModel } from "./index.ts";

describe("rewriteAliasModel", () => {
	test("rewrites the exact alias while preserving fields and input", () => {
		const payload = {
			model: "gpt-5.6-sol-1m",
			input: [{ role: "user", content: "hello" }],
			stream: true,
		};

		const rewritten = rewriteAliasModel(payload);

		expect(rewritten).toEqual({
			model: "gpt-5.6-sol",
			input: payload.input,
			stream: true,
		});
		expect(rewritten).not.toBe(payload);
		expect(payload.model).toBe("gpt-5.6-sol-1m");
	});

	test("does not rewrite other model IDs", () => {
		expect(rewriteAliasModel({ model: "gpt-5.6-sol", stream: true })).toBeUndefined();
		expect(rewriteAliasModel({ model: "gpt-5.6-sol-1m-preview" })).toBeUndefined();
	});

	test("does not replace non-object payloads", () => {
		expect(rewriteAliasModel(undefined)).toBeUndefined();
		expect(rewriteAliasModel(null)).toBeUndefined();
		expect(rewriteAliasModel("gpt-5.6-sol-1m")).toBeUndefined();
		expect(rewriteAliasModel(["gpt-5.6-sol-1m"])).toBeUndefined();
	});
});
