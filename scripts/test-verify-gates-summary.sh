#!/usr/bin/env bash
# test-verify-gates-summary - Validate verify-gates summary schema/renderer contract.
# Usage: ./scripts/test-verify-gates-summary.sh
# Delegates to: ./scripts/verify-gates.sh and ./scripts/publish-verify-gates-summary.sh in controlled mock scenarios.
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
else
	ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"
fi

cd "$ROOT"

tmpdir="$(mktemp -d)"
cleanup() {
	rm -rf "$tmpdir"
	unset -f make || true
}
trap cleanup EXIT

dry_summary="$tmpdir/dry.json"
dry_repeat_summary="$tmpdir/dry-repeat.json"
continue_true_summary="$tmpdir/continue-true.json"
continue_false_summary="$tmpdir/continue-false.json"
continue_flag_summary="$tmpdir/continue-flag.json"
continue_flag_step_summary="$tmpdir/continue-flag-step.md"
dedupe_summary="$tmpdir/dedupe.json"
from_summary="$tmpdir/from.json"
full_dry_summary="$tmpdir/full-dry.json"
default_mode_dry_summary="$tmpdir/default-mode-dry.json"
mode_precedence_full_summary="$tmpdir/mode-precedence-full.json"
mode_precedence_quick_summary="$tmpdir/mode-precedence-quick.json"
env_retries_summary="$tmpdir/env-retries.json"
cli_retries_override_summary="$tmpdir/cli-retries-override.json"
continue_fail_summary="$tmpdir/continue-fail.json"
continue_multi_fail_summary="$tmpdir/continue-multi-fail.json"
fail_fast_summary="$tmpdir/fail-fast.json"
retry_summary="$tmpdir/retry.json"
continue_fail_step_summary="$tmpdir/continue-fail-step.md"
continue_multi_fail_step_summary="$tmpdir/continue-multi-fail-step.md"
fail_fast_step_summary="$tmpdir/fail-fast-step.md"
retry_step_summary="$tmpdir/retry-step.md"
future_summary="$tmpdir/future.json"
future_step_summary="$tmpdir/future-step.md"
future_string_summary="$tmpdir/future-string.json"
future_string_step_summary="$tmpdir/future-string-step.md"
invalid_schema_version_summary="$tmpdir/invalid-schema-version.json"
invalid_schema_version_step_summary="$tmpdir/invalid-schema-version-step.md"
zero_schema_version_summary="$tmpdir/zero-schema-version.json"
zero_schema_version_step_summary="$tmpdir/zero-schema-version-step.md"
malformed_summary="$tmpdir/malformed\`name.json"
malformed_step_summary="$tmpdir/malformed-step.md"
missing_step_summary="$tmpdir/missing-step.md"
escape_summary="$tmpdir/escape.json"
escape_step_summary="$tmpdir/escape-step.md"
code_span_summary="$tmpdir/code-span.json"
code_span_step_summary="$tmpdir/code-span-step.md"
fallback_summary="$tmpdir/fallback.json"
fallback_step_summary="$tmpdir/fallback-step.md"
dry_fallback_summary="$tmpdir/dry-fallback.json"
dry_fallback_step_summary="$tmpdir/dry-fallback-step.md"
fail_fast_fallback_summary="$tmpdir/fail-fast-fallback.json"
fail_fast_fallback_step_summary="$tmpdir/fail-fast-fallback-step.md"
derived_counts_summary="$tmpdir/derived-counts.json"
derived_counts_step_summary="$tmpdir/derived-counts-step.md"
duplicate_gate_rows_summary="$tmpdir/duplicate-gate-rows.json"
duplicate_gate_rows_step_summary="$tmpdir/duplicate-gate-rows-step.md"
malformed_gate_rows_summary="$tmpdir/malformed-gate-rows.json"
malformed_gate_rows_step_summary="$tmpdir/malformed-gate-rows-step.md"
row_not_run_reason_type_summary="$tmpdir/row-not-run-reason-type.json"
row_not_run_reason_type_step_summary="$tmpdir/row-not-run-reason-type-step.md"
row_command_type_summary="$tmpdir/row-command-type.json"
row_command_type_step_summary="$tmpdir/row-command-type-step.md"
unknown_status_duplicate_rows_summary="$tmpdir/unknown-status-duplicate-rows.json"
unknown_status_duplicate_rows_step_summary="$tmpdir/unknown-status-duplicate-rows-step.md"
unknown_status_only_rows_summary="$tmpdir/unknown-status-only-rows.json"
unknown_status_only_rows_step_summary="$tmpdir/unknown-status-only-rows-step.md"
duplicate_same_status_rows_summary="$tmpdir/duplicate-same-status-rows.json"
duplicate_same_status_rows_step_summary="$tmpdir/duplicate-same-status-rows-step.md"
selected_order_rows_summary="$tmpdir/selected-order-rows.json"
selected_order_rows_step_summary="$tmpdir/selected-order-rows-step.md"
selected_order_missing_rows_summary="$tmpdir/selected-order-missing-rows.json"
selected_order_missing_rows_step_summary="$tmpdir/selected-order-missing-rows-step.md"
selected_order_unmatched_rows_summary="$tmpdir/selected-order-unmatched-rows.json"
selected_order_unmatched_rows_step_summary="$tmpdir/selected-order-unmatched-rows-step.md"
selected_subset_rows_summary="$tmpdir/selected-subset-rows.json"
selected_subset_rows_step_summary="$tmpdir/selected-subset-rows-step.md"
selected_empty_rows_summary="$tmpdir/selected-empty-rows.json"
selected_empty_rows_step_summary="$tmpdir/selected-empty-rows-step.md"
invocation_whitespace_summary="$tmpdir/invocation-whitespace.json"
invocation_whitespace_step_summary="$tmpdir/invocation-whitespace-step.md"
metadata_whitespace_summary="$tmpdir/metadata-whitespace.json"
metadata_whitespace_step_summary="$tmpdir/metadata-whitespace-step.md"
metadata_nonstring_summary="$tmpdir/metadata-nonstring.json"
metadata_nonstring_step_summary="$tmpdir/metadata-nonstring-step.md"
slow_fast_string_metadata_summary="$tmpdir/slow-fast-string-metadata.json"
slow_fast_string_metadata_step_summary="$tmpdir/slow-fast-string-metadata-step.md"
slow_fast_none_sentinel_metadata_summary="$tmpdir/slow-fast-none-sentinel-metadata.json"
slow_fast_none_sentinel_metadata_step_summary="$tmpdir/slow-fast-none-sentinel-metadata-step.md"
explicit_empty_attention_lists_summary="$tmpdir/explicit-empty-attention-lists.json"
explicit_empty_attention_lists_step_summary="$tmpdir/explicit-empty-attention-lists-step.md"
explicit_empty_non_success_with_retries_summary="$tmpdir/explicit-empty-non-success-with-retries.json"
explicit_empty_non_success_with_retries_step_summary="$tmpdir/explicit-empty-non-success-with-retries-step.md"
explicit_empty_attention_with_retries_summary="$tmpdir/explicit-empty-attention-with-retries.json"
explicit_empty_attention_with_retries_step_summary="$tmpdir/explicit-empty-attention-with-retries-step.md"
selected_status_map_scope_summary="$tmpdir/selected-status-map-scope.json"
selected_status_map_scope_step_summary="$tmpdir/selected-status-map-scope-step.md"
selected_status_counts_conflict_status_map_scope_summary="$tmpdir/selected-status-counts-conflict-status-map-scope.json"
selected_status_counts_conflict_status_map_scope_step_summary="$tmpdir/selected-status-counts-conflict-status-map-scope-step.md"
selected_status_counts_partial_malformed_status_map_scope_summary="$tmpdir/selected-status-counts-partial-malformed-status-map-scope.json"
selected_status_counts_partial_malformed_status_map_scope_step_summary="$tmpdir/selected-status-counts-partial-malformed-status-map-scope-step.md"
selected_status_counts_zero_raw_status_map_scope_summary="$tmpdir/selected-status-counts-zero-raw-status-map-scope.json"
selected_status_counts_zero_raw_status_map_scope_step_summary="$tmpdir/selected-status-counts-zero-raw-status-map-scope-step.md"
selected_status_counts_partial_status_map_partition_scope_summary="$tmpdir/selected-status-counts-partial-status-map-partition-scope.json"
selected_status_counts_partial_status_map_partition_scope_step_summary="$tmpdir/selected-status-counts-partial-status-map-partition-scope-step.md"
selected_scalar_failure_scope_summary="$tmpdir/selected-scalar-failure-scope.json"
selected_scalar_failure_scope_step_summary="$tmpdir/selected-scalar-failure-scope-step.md"
selected_scalar_counts_scope_summary="$tmpdir/selected-scalar-counts-scope.json"
selected_scalar_counts_scope_step_summary="$tmpdir/selected-scalar-counts-scope-step.md"
selected_status_counts_no_evidence_scope_summary="$tmpdir/selected-status-counts-no-evidence-scope.json"
selected_status_counts_no_evidence_scope_step_summary="$tmpdir/selected-status-counts-no-evidence-scope-step.md"
selected_status_counts_conflict_partition_scope_summary="$tmpdir/selected-status-counts-conflict-partition-scope.json"
selected_status_counts_conflict_partition_scope_step_summary="$tmpdir/selected-status-counts-conflict-partition-scope-step.md"
selected_scalar_raw_count_mix_partition_scope_summary="$tmpdir/selected-scalar-raw-count-mix-partition-scope.json"
selected_scalar_raw_count_mix_partition_scope_step_summary="$tmpdir/selected-scalar-raw-count-mix-partition-scope-step.md"
selected_status_counts_partial_malformed_partition_scope_summary="$tmpdir/selected-status-counts-partial-malformed-partition-scope.json"
selected_status_counts_partial_malformed_partition_scope_step_summary="$tmpdir/selected-status-counts-partial-malformed-partition-scope-step.md"
selected_status_counts_zero_raw_partition_scope_summary="$tmpdir/selected-status-counts-zero-raw-partition-scope.json"
selected_status_counts_zero_raw_partition_scope_step_summary="$tmpdir/selected-status-counts-zero-raw-partition-scope-step.md"
selected_failed_exit_code_alignment_summary="$tmpdir/selected-failed-exit-code-alignment.json"
selected_failed_exit_code_alignment_step_summary="$tmpdir/selected-failed-exit-code-alignment-step.md"
selected_slow_fast_scope_summary="$tmpdir/selected-slow-fast-scope.json"
selected_slow_fast_scope_step_summary="$tmpdir/selected-slow-fast-scope-step.md"
selected_aggregate_metrics_scope_summary="$tmpdir/selected-aggregate-metrics-scope.json"
selected_aggregate_metrics_scope_step_summary="$tmpdir/selected-aggregate-metrics-scope-step.md"
selected_aggregate_metrics_string_scalar_scope_summary="$tmpdir/selected-aggregate-metrics-string-scalar-scope.json"
selected_aggregate_metrics_string_scalar_scope_step_summary="$tmpdir/selected-aggregate-metrics-string-scalar-scope-step.md"
selected_aggregate_metrics_decimal_string_scope_summary="$tmpdir/selected-aggregate-metrics-decimal-string-scope.json"
selected_aggregate_metrics_decimal_string_scope_step_summary="$tmpdir/selected-aggregate-metrics-decimal-string-scope-step.md"
selected_aggregate_metrics_scientific_string_scope_summary="$tmpdir/selected-aggregate-metrics-scientific-string-scope.json"
selected_aggregate_metrics_scientific_string_scope_step_summary="$tmpdir/selected-aggregate-metrics-scientific-string-scope-step.md"
selected_aggregate_metrics_float_scalar_scope_summary="$tmpdir/selected-aggregate-metrics-float-scalar-scope.json"
selected_aggregate_metrics_float_scalar_scope_step_summary="$tmpdir/selected-aggregate-metrics-float-scalar-scope-step.md"
selected_aggregate_metrics_rate_scalar_overflow_scope_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-overflow-scope.json"
selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-overflow-scope-step.md"
selected_aggregate_metrics_rate_scalar_boundary_scope_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-boundary-scope.json"
selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-boundary-scope-step.md"
selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-mixed-boundary-scope.json"
selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-mixed-boundary-scope-step.md"
selected_aggregate_metrics_malformed_scope_summary="$tmpdir/selected-aggregate-metrics-malformed-scope.json"
selected_aggregate_metrics_malformed_scope_step_summary="$tmpdir/selected-aggregate-metrics-malformed-scope-step.md"
selected_aggregate_metrics_no_evidence_scope_summary="$tmpdir/selected-aggregate-metrics-no-evidence-scope.json"
selected_aggregate_metrics_no_evidence_scope_step_summary="$tmpdir/selected-aggregate-metrics-no-evidence-scope-step.md"
selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-overflow-no-evidence-scope.json"
selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-overflow-no-evidence-scope-step.md"
selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-scope.json"
selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-scope-step.md"
selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-string-scope.json"
selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary="$tmpdir/selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-string-scope-step.md"
selected_aggregate_metrics_nonselected_evidence_scope_summary="$tmpdir/selected-aggregate-metrics-nonselected-evidence-scope.json"
selected_aggregate_metrics_nonselected_evidence_scope_step_summary="$tmpdir/selected-aggregate-metrics-nonselected-evidence-scope-step.md"
selected_aggregate_metrics_no_evidence_string_scope_summary="$tmpdir/selected-aggregate-metrics-no-evidence-string-scope.json"
selected_aggregate_metrics_no_evidence_string_scope_step_summary="$tmpdir/selected-aggregate-metrics-no-evidence-string-scope-step.md"
selected_aggregate_metrics_no_evidence_plus_string_scope_summary="$tmpdir/selected-aggregate-metrics-no-evidence-plus-string-scope.json"
selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary="$tmpdir/selected-aggregate-metrics-no-evidence-plus-string-scope-step.md"
selected_aggregate_metrics_no_evidence_mixed_invalid_scope_summary="$tmpdir/selected-aggregate-metrics-no-evidence-mixed-invalid-scope.json"
selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary="$tmpdir/selected-aggregate-metrics-no-evidence-mixed-invalid-scope-step.md"
selected_failed_exit_codes_without_ids_scope_summary="$tmpdir/selected-failed-exit-codes-without-ids-scope.json"
selected_failed_exit_codes_without_ids_scope_step_summary="$tmpdir/selected-failed-exit-codes-without-ids-scope-step.md"
selected_timestamps_scope_summary="$tmpdir/selected-timestamps-scope.json"
selected_timestamps_scope_step_summary="$tmpdir/selected-timestamps-scope-step.md"
selected_timestamps_no_rows_scope_summary="$tmpdir/selected-timestamps-no-rows-scope.json"
selected_timestamps_no_rows_scope_step_summary="$tmpdir/selected-timestamps-no-rows-scope-step.md"
selected_timestamps_invalid_no_rows_scope_summary="$tmpdir/selected-timestamps-invalid-no-rows-scope.json"
selected_timestamps_invalid_no_rows_scope_step_summary="$tmpdir/selected-timestamps-invalid-no-rows-scope-step.md"
selected_timestamps_leap_valid_no_rows_scope_summary="$tmpdir/selected-timestamps-leap-valid-no-rows-scope.json"
selected_timestamps_leap_valid_no_rows_scope_step_summary="$tmpdir/selected-timestamps-leap-valid-no-rows-scope-step.md"
selected_timestamps_nonleap_century_invalid_no_rows_scope_summary="$tmpdir/selected-timestamps-nonleap-century-invalid-no-rows-scope.json"
selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary="$tmpdir/selected-timestamps-nonleap-century-invalid-no-rows-scope-step.md"
selected_timestamps_century_leap_valid_no_rows_scope_summary="$tmpdir/selected-timestamps-century-leap-valid-no-rows-scope.json"
selected_timestamps_century_leap_valid_no_rows_scope_step_summary="$tmpdir/selected-timestamps-century-leap-valid-no-rows-scope-step.md"
selected_timestamps_invalid_second_no_rows_scope_summary="$tmpdir/selected-timestamps-invalid-second-no-rows-scope.json"
selected_timestamps_invalid_second_no_rows_scope_step_summary="$tmpdir/selected-timestamps-invalid-second-no-rows-scope-step.md"
selected_timestamps_invalid_hour_no_rows_scope_summary="$tmpdir/selected-timestamps-invalid-hour-no-rows-scope.json"
selected_timestamps_invalid_hour_no_rows_scope_step_summary="$tmpdir/selected-timestamps-invalid-hour-no-rows-scope-step.md"
selected_timestamps_invalid_minute_no_rows_scope_summary="$tmpdir/selected-timestamps-invalid-minute-no-rows-scope.json"
selected_timestamps_invalid_minute_no_rows_scope_step_summary="$tmpdir/selected-timestamps-invalid-minute-no-rows-scope-step.md"
selected_timestamps_year_boundary_valid_no_rows_scope_summary="$tmpdir/selected-timestamps-year-boundary-valid-no-rows-scope.json"
selected_timestamps_year_boundary_valid_no_rows_scope_step_summary="$tmpdir/selected-timestamps-year-boundary-valid-no-rows-scope-step.md"
selected_timestamps_day_boundary_valid_no_rows_scope_summary="$tmpdir/selected-timestamps-day-boundary-valid-no-rows-scope.json"
selected_timestamps_day_boundary_valid_no_rows_scope_step_summary="$tmpdir/selected-timestamps-day-boundary-valid-no-rows-scope-step.md"
selected_timestamps_whitespace_no_rows_scope_summary="$tmpdir/selected-timestamps-whitespace-no-rows-scope.json"
selected_timestamps_whitespace_no_rows_scope_step_summary="$tmpdir/selected-timestamps-whitespace-no-rows-scope-step.md"
selected_timestamps_conflicting_no_rows_scope_summary="$tmpdir/selected-timestamps-conflicting-no-rows-scope.json"
selected_timestamps_conflicting_no_rows_scope_step_summary="$tmpdir/selected-timestamps-conflicting-no-rows-scope-step.md"
selected_timestamps_unmatched_rows_scope_summary="$tmpdir/selected-timestamps-unmatched-rows-scope.json"
selected_timestamps_unmatched_rows_scope_step_summary="$tmpdir/selected-timestamps-unmatched-rows-scope-step.md"
selected_timestamps_unmatched_rows_malformed_explicit_scope_summary="$tmpdir/selected-timestamps-unmatched-rows-malformed-explicit-scope.json"
selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary="$tmpdir/selected-timestamps-unmatched-rows-malformed-explicit-scope-step.md"
selected_timestamps_malformed_rows_scope_summary="$tmpdir/selected-timestamps-malformed-rows-scope.json"
selected_timestamps_malformed_rows_scope_step_summary="$tmpdir/selected-timestamps-malformed-rows-scope-step.md"
selected_timestamps_malformed_rows_explicit_scope_summary="$tmpdir/selected-timestamps-malformed-rows-explicit-scope.json"
selected_timestamps_malformed_rows_explicit_scope_step_summary="$tmpdir/selected-timestamps-malformed-rows-explicit-scope-step.md"
selected_duration_zero_map_no_rows_scope_summary="$tmpdir/selected-duration-zero-map-no-rows-scope.json"
selected_duration_zero_map_no_rows_scope_step_summary="$tmpdir/selected-duration-zero-map-no-rows-scope-step.md"
timestamps_malformed_explicit_unscoped_summary="$tmpdir/timestamps-malformed-explicit-unscoped.json"
timestamps_malformed_explicit_unscoped_step_summary="$tmpdir/timestamps-malformed-explicit-unscoped-step.md"
timestamps_invalid_explicit_no_rows_unscoped_summary="$tmpdir/timestamps-invalid-explicit-no-rows-unscoped.json"
timestamps_invalid_explicit_no_rows_unscoped_step_summary="$tmpdir/timestamps-invalid-explicit-no-rows-unscoped-step.md"
timestamps_whitespace_no_rows_unscoped_summary="$tmpdir/timestamps-whitespace-no-rows-unscoped.json"
timestamps_whitespace_no_rows_unscoped_step_summary="$tmpdir/timestamps-whitespace-no-rows-unscoped-step.md"
timestamps_conflicting_no_rows_unscoped_summary="$tmpdir/timestamps-conflicting-no-rows-unscoped.json"
timestamps_conflicting_no_rows_unscoped_step_summary="$tmpdir/timestamps-conflicting-no-rows-unscoped-step.md"
timestamps_conflicting_no_rows_with_explicit_total_unscoped_summary="$tmpdir/timestamps-conflicting-no-rows-with-explicit-total-unscoped.json"
timestamps_conflicting_no_rows_with_explicit_total_unscoped_step_summary="$tmpdir/timestamps-conflicting-no-rows-with-explicit-total-unscoped-step.md"
total_duration_conflict_duration_map_no_rows_unscoped_summary="$tmpdir/total-duration-conflict-duration-map-no-rows-unscoped.json"
total_duration_conflict_duration_map_no_rows_unscoped_step_summary="$tmpdir/total-duration-conflict-duration-map-no-rows-unscoped-step.md"
selected_total_duration_no_rows_scope_summary="$tmpdir/selected-total-duration-no-rows-scope.json"
selected_total_duration_no_rows_scope_step_summary="$tmpdir/selected-total-duration-no-rows-scope-step.md"
selected_total_duration_conflict_duration_map_no_rows_scope_summary="$tmpdir/selected-total-duration-conflict-duration-map-no-rows-scope.json"
selected_total_duration_conflict_duration_map_no_rows_scope_step_summary="$tmpdir/selected-total-duration-conflict-duration-map-no-rows-scope-step.md"
selected_total_duration_conflict_zero_duration_map_no_rows_scope_summary="$tmpdir/selected-total-duration-conflict-zero-duration-map-no-rows-scope.json"
selected_total_duration_conflict_zero_duration_map_no_rows_scope_step_summary="$tmpdir/selected-total-duration-conflict-zero-duration-map-no-rows-scope-step.md"
selected_total_duration_nonselected_duration_map_no_rows_scope_summary="$tmpdir/selected-total-duration-nonselected-duration-map-no-rows-scope.json"
selected_total_duration_nonselected_duration_map_no_rows_scope_step_summary="$tmpdir/selected-total-duration-nonselected-duration-map-no-rows-scope-step.md"
selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_summary="$tmpdir/selected-total-duration-nonselected-duration-map-without-explicit-no-rows-scope.json"
selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_step_summary="$tmpdir/selected-total-duration-nonselected-duration-map-without-explicit-no-rows-scope-step.md"
selected_total_duration_conflicting_timestamps_no_rows_scope_summary="$tmpdir/selected-total-duration-conflicting-timestamps-no-rows-scope.json"
selected_total_duration_conflicting_timestamps_no_rows_scope_step_summary="$tmpdir/selected-total-duration-conflicting-timestamps-no-rows-scope-step.md"
selected_run_state_scope_summary="$tmpdir/selected-run-state-scope.json"
selected_run_state_scope_step_summary="$tmpdir/selected-run-state-scope-step.md"
selected_run_state_no_evidence_scope_summary="$tmpdir/selected-run-state-no-evidence-scope.json"
selected_run_state_no_evidence_scope_step_summary="$tmpdir/selected-run-state-no-evidence-scope-step.md"
selected_run_state_nonselected_evidence_scope_summary="$tmpdir/selected-run-state-nonselected-evidence-scope.json"
selected_run_state_nonselected_evidence_scope_step_summary="$tmpdir/selected-run-state-nonselected-evidence-scope-step.md"
selected_run_state_unknown_status_scope_summary="$tmpdir/selected-run-state-unknown-status-scope.json"
selected_run_state_unknown_status_scope_step_summary="$tmpdir/selected-run-state-unknown-status-scope-step.md"
selected_run_state_partial_status_scope_summary="$tmpdir/selected-run-state-partial-status-scope.json"
selected_run_state_partial_status_scope_step_summary="$tmpdir/selected-run-state-partial-status-scope-step.md"
selected_run_state_failure_scope_summary="$tmpdir/selected-run-state-failure-scope.json"
selected_run_state_failure_scope_step_summary="$tmpdir/selected-run-state-failure-scope-step.md"
selected_run_state_not_run_scope_summary="$tmpdir/selected-run-state-not-run-scope.json"
selected_run_state_not_run_scope_step_summary="$tmpdir/selected-run-state-not-run-scope-step.md"
selected_run_state_not_run_blocked_selected_scope_summary="$tmpdir/selected-run-state-not-run-blocked-selected-scope.json"
selected_run_state_not_run_blocked_selected_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-selected-scope-step.md"
selected_run_state_not_run_blocked_selected_whitespace_scope_summary="$tmpdir/selected-run-state-not-run-blocked-selected-whitespace-scope.json"
selected_run_state_not_run_blocked_selected_whitespace_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-selected-whitespace-scope-step.md"
selected_run_state_not_run_blocked_selected_uppercase_scope_summary="$tmpdir/selected-run-state-not-run-blocked-selected-uppercase-scope.json"
selected_run_state_not_run_blocked_selected_uppercase_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-selected-uppercase-scope-step.md"
selected_run_state_not_run_blocked_selected_spaced_colon_scope_summary="$tmpdir/selected-run-state-not-run-blocked-selected-spaced-colon-scope.json"
selected_run_state_not_run_blocked_selected_spaced_colon_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-selected-spaced-colon-scope-step.md"
selected_run_state_not_run_blocked_empty_scope_summary="$tmpdir/selected-run-state-not-run-blocked-empty-scope.json"
selected_run_state_not_run_blocked_empty_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-empty-scope-step.md"
selected_run_state_not_run_blocked_none_sentinel_scope_summary="$tmpdir/selected-run-state-not-run-blocked-none-sentinel-scope.json"
selected_run_state_not_run_blocked_none_sentinel_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-none-sentinel-scope-step.md"
selected_run_state_not_run_blocked_selected_continue_scope_summary="$tmpdir/selected-run-state-not-run-blocked-selected-continue-scope.json"
selected_run_state_not_run_blocked_selected_continue_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-selected-continue-scope-step.md"
selected_run_state_not_run_blocked_selected_dry_reason_scope_summary="$tmpdir/selected-run-state-not-run-blocked-selected-dry-reason-scope.json"
selected_run_state_not_run_blocked_selected_dry_reason_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-selected-dry-reason-scope-step.md"
selected_run_state_not_run_blocked_selected_continued_conflict_scope_summary="$tmpdir/selected-run-state-not-run-blocked-selected-continued-conflict-scope.json"
selected_run_state_not_run_blocked_selected_continued_conflict_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-selected-continued-conflict-scope-step.md"
selected_run_state_not_run_blocked_nonselected_scope_summary="$tmpdir/selected-run-state-not-run-blocked-nonselected-scope.json"
selected_run_state_not_run_blocked_nonselected_scope_step_summary="$tmpdir/selected-run-state-not-run-blocked-nonselected-scope-step.md"
selected_run_state_scalar_failure_only_scope_summary="$tmpdir/selected-run-state-scalar-failure-only-scope.json"
selected_run_state_scalar_failure_only_scope_step_summary="$tmpdir/selected-run-state-scalar-failure-only-scope-step.md"
selected_run_state_scalar_blocked_only_scope_summary="$tmpdir/selected-run-state-scalar-blocked-only-scope.json"
selected_run_state_scalar_blocked_only_scope_step_summary="$tmpdir/selected-run-state-scalar-blocked-only-scope-step.md"
selected_run_state_scalar_blocked_whitespace_scope_summary="$tmpdir/selected-run-state-scalar-blocked-whitespace-scope.json"
selected_run_state_scalar_blocked_whitespace_scope_step_summary="$tmpdir/selected-run-state-scalar-blocked-whitespace-scope-step.md"
selected_run_state_scalar_blocked_empty_scope_summary="$tmpdir/selected-run-state-scalar-blocked-empty-scope.json"
selected_run_state_scalar_blocked_empty_scope_step_summary="$tmpdir/selected-run-state-scalar-blocked-empty-scope-step.md"
selected_run_state_scalar_blocked_continue_scope_summary="$tmpdir/selected-run-state-scalar-blocked-continue-scope.json"
selected_run_state_scalar_blocked_continue_scope_step_summary="$tmpdir/selected-run-state-scalar-blocked-continue-scope-step.md"
selected_run_state_scalar_blocked_dry_run_scope_summary="$tmpdir/selected-run-state-scalar-blocked-dry-run-scope.json"
selected_run_state_scalar_blocked_dry_run_scope_step_summary="$tmpdir/selected-run-state-scalar-blocked-dry-run-scope-step.md"
selected_run_state_scalar_blocked_dry_reason_scope_summary="$tmpdir/selected-run-state-scalar-blocked-dry-reason-scope.json"
selected_run_state_scalar_blocked_dry_reason_scope_step_summary="$tmpdir/selected-run-state-scalar-blocked-dry-reason-scope-step.md"
selected_run_state_scalar_blocked_continued_conflict_scope_summary="$tmpdir/selected-run-state-scalar-blocked-continued-conflict-scope.json"
selected_run_state_scalar_blocked_continued_conflict_scope_step_summary="$tmpdir/selected-run-state-scalar-blocked-continued-conflict-scope-step.md"
selected_run_state_nonselected_blocked_scope_summary="$tmpdir/selected-run-state-nonselected-blocked-scope.json"
selected_run_state_nonselected_blocked_scope_step_summary="$tmpdir/selected-run-state-nonselected-blocked-scope-step.md"
selected_run_state_blocked_reason_pass_status_scope_summary="$tmpdir/selected-run-state-blocked-reason-pass-status-scope.json"
selected_run_state_blocked_reason_pass_status_scope_step_summary="$tmpdir/selected-run-state-blocked-reason-pass-status-scope-step.md"
selected_run_state_blocked_scalar_precedence_scope_summary="$tmpdir/selected-run-state-blocked-scalar-precedence-scope.json"
selected_run_state_blocked_scalar_precedence_scope_step_summary="$tmpdir/selected-run-state-blocked-scalar-precedence-scope-step.md"
selected_run_state_blocked_reason_not_run_list_scope_summary="$tmpdir/selected-run-state-blocked-reason-not-run-list-scope.json"
selected_run_state_blocked_reason_not_run_list_scope_step_summary="$tmpdir/selected-run-state-blocked-reason-not-run-list-scope-step.md"
selected_run_state_blocked_reason_unknown_status_not_run_list_scope_summary="$tmpdir/selected-run-state-blocked-reason-unknown-status-not-run-list-scope.json"
selected_run_state_blocked_reason_unknown_status_not_run_list_scope_step_summary="$tmpdir/selected-run-state-blocked-reason-unknown-status-not-run-list-scope-step.md"
selected_run_state_blocked_reason_selected_order_scope_summary="$tmpdir/selected-run-state-blocked-reason-selected-order-scope.json"
selected_run_state_blocked_reason_selected_order_scope_step_summary="$tmpdir/selected-run-state-blocked-reason-selected-order-scope-step.md"
selected_non_success_partition_fallback_scope_summary="$tmpdir/selected-non-success-partition-fallback-scope.json"
selected_non_success_partition_fallback_scope_step_summary="$tmpdir/selected-non-success-partition-fallback-scope-step.md"
selected_non_success_status_precedence_scope_summary="$tmpdir/selected-non-success-status-precedence-scope.json"
selected_non_success_status_precedence_scope_step_summary="$tmpdir/selected-non-success-status-precedence-scope-step.md"
selected_explicit_empty_partition_lists_status_map_scope_summary="$tmpdir/selected-explicit-empty-partition-lists-status-map-scope.json"
selected_explicit_empty_partition_lists_status_map_scope_step_summary="$tmpdir/selected-explicit-empty-partition-lists-status-map-scope-step.md"
selected_executed_fallback_empty_status_map_scope_summary="$tmpdir/selected-executed-fallback-empty-status-map-scope.json"
selected_executed_fallback_empty_status_map_scope_step_summary="$tmpdir/selected-executed-fallback-empty-status-map-scope-step.md"
selected_executed_explicit_empty_list_scope_summary="$tmpdir/selected-executed-explicit-empty-list-scope.json"
selected_executed_explicit_empty_list_scope_step_summary="$tmpdir/selected-executed-explicit-empty-list-scope-step.md"
selected_executed_scalar_count_ignored_empty_list_scope_summary="$tmpdir/selected-executed-scalar-count-ignored-empty-list-scope.json"
selected_executed_scalar_count_ignored_empty_list_scope_step_summary="$tmpdir/selected-executed-scalar-count-ignored-empty-list-scope-step.md"
selected_executed_fallback_partial_status_map_scope_summary="$tmpdir/selected-executed-fallback-partial-status-map-scope.json"
selected_executed_fallback_partial_status_map_scope_step_summary="$tmpdir/selected-executed-fallback-partial-status-map-scope-step.md"
selected_attention_retried_scope_summary="$tmpdir/selected-attention-retried-scope.json"
selected_attention_retried_scope_step_summary="$tmpdir/selected-attention-retried-scope-step.md"
selected_attention_retried_without_map_scope_summary="$tmpdir/selected-attention-retried-without-map-scope.json"
selected_attention_retried_without_map_scope_step_summary="$tmpdir/selected-attention-retried-without-map-scope-step.md"
explicit_retried_zero_count_retry_map_summary="$tmpdir/explicit-retried-zero-count-retry-map.json"
explicit_retried_zero_count_retry_map_step_summary="$tmpdir/explicit-retried-zero-count-retry-map-step.md"
explicit_retried_subset_retry_map_summary="$tmpdir/explicit-retried-subset-retry-map.json"
explicit_retried_subset_retry_map_step_summary="$tmpdir/explicit-retried-subset-retry-map-step.md"
explicit_retried_missing_retry_map_key_summary="$tmpdir/explicit-retried-missing-retry-map-key.json"
explicit_retried_missing_retry_map_key_step_summary="$tmpdir/explicit-retried-missing-retry-map-key-step.md"
explicit_empty_retried_with_retry_map_summary="$tmpdir/explicit-empty-retried-with-retry-map.json"
explicit_empty_retried_with_retry_map_step_summary="$tmpdir/explicit-empty-retried-with-retry-map-step.md"
scalar_failed_gate_with_empty_failed_ids_summary="$tmpdir/scalar-failed-gate-with-empty-failed-ids.json"
scalar_failed_gate_with_empty_failed_ids_step_summary="$tmpdir/scalar-failed-gate-with-empty-failed-ids-step.md"
scalar_failed_gate_selected_fallback_summary="$tmpdir/scalar-failed-gate-selected-fallback.json"
scalar_failed_gate_selected_fallback_step_summary="$tmpdir/scalar-failed-gate-selected-fallback-step.md"
scalar_blocked_gate_selected_fallback_summary="$tmpdir/scalar-blocked-gate-selected-fallback.json"
scalar_blocked_gate_selected_fallback_step_summary="$tmpdir/scalar-blocked-gate-selected-fallback-step.md"
scalar_none_sentinel_gate_ids_summary="$tmpdir/scalar-none-sentinel-gate-ids.json"
scalar_none_sentinel_gate_ids_step_summary="$tmpdir/scalar-none-sentinel-gate-ids-step.md"
scalar_none_sentinel_gate_ids_case_scope_summary="$tmpdir/scalar-none-sentinel-gate-ids-case-scope.json"
scalar_none_sentinel_gate_ids_case_scope_step_summary="$tmpdir/scalar-none-sentinel-gate-ids-case-scope-step.md"
selected_explicit_attention_scope_summary="$tmpdir/selected-explicit-attention-scope.json"
selected_explicit_attention_scope_step_summary="$tmpdir/selected-explicit-attention-scope-step.md"
selected_partition_list_overlap_scope_summary="$tmpdir/selected-partition-list-overlap-scope.json"
selected_partition_list_overlap_scope_step_summary="$tmpdir/selected-partition-list-overlap-scope-step.md"
selected_partition_list_malformed_counts_scope_summary="$tmpdir/selected-partition-list-malformed-counts-scope.json"
selected_partition_list_malformed_counts_scope_step_summary="$tmpdir/selected-partition-list-malformed-counts-scope-step.md"
selected_explicit_empty_attention_with_retries_scope_summary="$tmpdir/selected-explicit-empty-attention-with-retries-scope.json"
selected_explicit_empty_attention_with_retries_scope_step_summary="$tmpdir/selected-explicit-empty-attention-with-retries-scope-step.md"
selected_explicit_empty_non_success_with_retries_scope_summary="$tmpdir/selected-explicit-empty-non-success-with-retries-scope.json"
selected_explicit_empty_non_success_with_retries_scope_step_summary="$tmpdir/selected-explicit-empty-non-success-with-retries-scope-step.md"
selected_explicit_empty_retried_with_retry_map_scope_summary="$tmpdir/selected-explicit-empty-retried-with-retry-map-scope.json"
selected_explicit_empty_retried_with_retry_map_scope_step_summary="$tmpdir/selected-explicit-empty-retried-with-retry-map-scope-step.md"
selected_explicit_retried_subset_retry_map_scope_summary="$tmpdir/selected-explicit-retried-subset-retry-map-scope.json"
selected_explicit_retried_subset_retry_map_scope_step_summary="$tmpdir/selected-explicit-retried-subset-retry-map-scope-step.md"
selected_explicit_retried_zero_count_retry_map_scope_summary="$tmpdir/selected-explicit-retried-zero-count-retry-map-scope.json"
selected_explicit_retried_zero_count_retry_map_scope_step_summary="$tmpdir/selected-explicit-retried-zero-count-retry-map-scope-step.md"
selected_explicit_retried_missing_retry_map_key_scope_summary="$tmpdir/selected-explicit-retried-missing-retry-map-key-scope.json"
selected_explicit_retried_missing_retry_map_key_scope_step_summary="$tmpdir/selected-explicit-retried-missing-retry-map-key-scope-step.md"
selected_explicit_retried_missing_retry_map_key_with_map_scope_summary="$tmpdir/selected-explicit-retried-missing-retry-map-key-with-map-scope.json"
selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary="$tmpdir/selected-explicit-retried-missing-retry-map-key-with-map-scope-step.md"
selected_explicit_retried_subset_over_rows_scope_summary="$tmpdir/selected-explicit-retried-subset-over-rows-scope.json"
selected_explicit_retried_subset_over_rows_scope_step_summary="$tmpdir/selected-explicit-retried-subset-over-rows-scope-step.md"
selected_explicit_retried_nonselected_scope_summary="$tmpdir/selected-explicit-retried-nonselected-scope.json"
selected_explicit_retried_nonselected_scope_step_summary="$tmpdir/selected-explicit-retried-nonselected-scope-step.md"
selected_run_state_unmatched_rows_scope_summary="$tmpdir/selected-run-state-unmatched-rows-scope.json"
selected_run_state_unmatched_rows_scope_step_summary="$tmpdir/selected-run-state-unmatched-rows-scope-step.md"
unscoped_aggregate_metrics_explicit_precedence_summary="$tmpdir/unscoped-aggregate-metrics-explicit-precedence.json"
unscoped_aggregate_metrics_explicit_precedence_step_summary="$tmpdir/unscoped-aggregate-metrics-explicit-precedence-step.md"
unscoped_aggregate_metrics_explicit_no_evidence_summary="$tmpdir/unscoped-aggregate-metrics-explicit-no-evidence.json"
unscoped_aggregate_metrics_explicit_no_evidence_step_summary="$tmpdir/unscoped-aggregate-metrics-explicit-no-evidence-step.md"
unscoped_aggregate_metrics_explicit_no_evidence_string_summary="$tmpdir/unscoped-aggregate-metrics-explicit-no-evidence-string.json"
unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary="$tmpdir/unscoped-aggregate-metrics-explicit-no-evidence-string-step.md"
unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_summary="$tmpdir/unscoped-aggregate-metrics-explicit-no-evidence-string-whitespace.json"
unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary="$tmpdir/unscoped-aggregate-metrics-explicit-no-evidence-string-whitespace-step.md"
unscoped_aggregate_metrics_explicit_no_evidence_string_plus_summary="$tmpdir/unscoped-aggregate-metrics-explicit-no-evidence-string-plus.json"
unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary="$tmpdir/unscoped-aggregate-metrics-explicit-no-evidence-string-plus-step.md"
unscoped_aggregate_metrics_no_evidence_mixed_invalid_summary="$tmpdir/unscoped-aggregate-metrics-no-evidence-mixed-invalid.json"
unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary="$tmpdir/unscoped-aggregate-metrics-no-evidence-mixed-invalid-step.md"
unscoped_aggregate_metrics_decimal_string_fallback_summary="$tmpdir/unscoped-aggregate-metrics-decimal-string-fallback.json"
unscoped_aggregate_metrics_decimal_string_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-decimal-string-fallback-step.md"
unscoped_aggregate_metrics_float_scalar_fallback_summary="$tmpdir/unscoped-aggregate-metrics-float-scalar-fallback.json"
unscoped_aggregate_metrics_float_scalar_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-float-scalar-fallback-step.md"
unscoped_aggregate_metrics_scientific_string_fallback_summary="$tmpdir/unscoped-aggregate-metrics-scientific-string-fallback.json"
unscoped_aggregate_metrics_scientific_string_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-scientific-string-fallback-step.md"
unscoped_aggregate_metrics_string_scalar_precedence_summary="$tmpdir/unscoped-aggregate-metrics-string-scalar-precedence.json"
unscoped_aggregate_metrics_string_scalar_precedence_step_summary="$tmpdir/unscoped-aggregate-metrics-string-scalar-precedence-step.md"
unscoped_aggregate_metrics_partial_scalar_precedence_summary="$tmpdir/unscoped-aggregate-metrics-partial-scalar-precedence.json"
unscoped_aggregate_metrics_partial_scalar_precedence_step_summary="$tmpdir/unscoped-aggregate-metrics-partial-scalar-precedence-step.md"
unscoped_aggregate_metrics_negative_fallback_summary="$tmpdir/unscoped-aggregate-metrics-negative-fallback.json"
unscoped_aggregate_metrics_negative_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-negative-fallback-step.md"
unscoped_aggregate_metrics_malformed_fallback_summary="$tmpdir/unscoped-aggregate-metrics-malformed-fallback.json"
unscoped_aggregate_metrics_malformed_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-malformed-fallback-step.md"
unscoped_aggregate_metrics_malformed_no_evidence_fallback_summary="$tmpdir/unscoped-aggregate-metrics-malformed-no-evidence-fallback.json"
unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-malformed-no-evidence-fallback-step.md"
unscoped_aggregate_metrics_rate_scalar_overflow_fallback_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-overflow-fallback.json"
unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-overflow-fallback-step.md"
unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-overflow-no-evidence-fallback.json"
unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-overflow-no-evidence-fallback-step.md"
unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-upper-bound-precedence.json"
unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_step_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-upper-bound-precedence-step.md"
unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-precedence.json"
unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_step_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-precedence-step.md"
unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_summary="$tmpdir/unscoped-aggregate-metrics-retry-rate-scalar-count-clamp-fallback.json"
unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-retry-rate-scalar-count-clamp-fallback-step.md"
unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-lower-bound-precedence.json"
unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_step_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-lower-bound-precedence-step.md"
unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-mixed-boundary-precedence.json"
unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_step_summary="$tmpdir/unscoped-aggregate-metrics-rate-scalar-mixed-boundary-precedence-step.md"
unscoped_aggregate_metrics_rate_derived_clamp_fallback_summary="$tmpdir/unscoped-aggregate-metrics-rate-derived-clamp-fallback.json"
unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary="$tmpdir/unscoped-aggregate-metrics-rate-derived-clamp-fallback-step.md"
derived_lists_summary="$tmpdir/derived-lists.json"
derived_lists_step_summary="$tmpdir/derived-lists-step.md"
unscoped_partition_scalar_counts_precedence_summary="$tmpdir/unscoped-partition-scalar-counts-precedence.json"
unscoped_partition_scalar_counts_precedence_step_summary="$tmpdir/unscoped-partition-scalar-counts-precedence-step.md"
unscoped_partition_scalar_vs_status_counts_conflict_summary="$tmpdir/unscoped-partition-scalar-vs-status-counts-conflict.json"
unscoped_partition_scalar_vs_status_counts_conflict_step_summary="$tmpdir/unscoped-partition-scalar-vs-status-counts-conflict-step.md"
unscoped_partition_scalar_zero_raw_status_counts_conflict_summary="$tmpdir/unscoped-partition-scalar-zero-raw-status-counts-conflict.json"
unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary="$tmpdir/unscoped-partition-scalar-zero-raw-status-counts-conflict-step.md"
unscoped_partition_scalar_partial_zero_raw_status_counts_mix_summary="$tmpdir/unscoped-partition-scalar-partial-zero-raw-status-counts-mix.json"
unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary="$tmpdir/unscoped-partition-scalar-partial-zero-raw-status-counts-mix-step.md"
unscoped_partition_scalar_partial_mix_summary="$tmpdir/unscoped-partition-scalar-partial-mix.json"
unscoped_partition_scalar_partial_mix_step_summary="$tmpdir/unscoped-partition-scalar-partial-mix-step.md"
unscoped_partition_scalar_raw_list_hybrid_summary="$tmpdir/unscoped-partition-scalar-raw-list-hybrid.json"
unscoped_partition_scalar_raw_list_hybrid_step_summary="$tmpdir/unscoped-partition-scalar-raw-list-hybrid-step.md"
unscoped_partition_scalar_raw_list_status_map_hybrid_summary="$tmpdir/unscoped-partition-scalar-raw-list-status-map-hybrid.json"
unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary="$tmpdir/unscoped-partition-scalar-raw-list-status-map-hybrid-step.md"
unscoped_partition_scalar_invalid_fallback_status_counts_summary="$tmpdir/unscoped-partition-scalar-invalid-fallback-status-counts.json"
unscoped_partition_scalar_invalid_fallback_status_counts_step_summary="$tmpdir/unscoped-partition-scalar-invalid-fallback-status-counts-step.md"
unscoped_status_counts_partial_status_map_fallback_summary="$tmpdir/unscoped-status-counts-partial-status-map-fallback.json"
unscoped_status_counts_partial_status_map_fallback_step_summary="$tmpdir/unscoped-status-counts-partial-status-map-fallback-step.md"
unscoped_status_counts_zero_authoritative_summary="$tmpdir/unscoped-status-counts-zero-authoritative.json"
unscoped_status_counts_zero_authoritative_step_summary="$tmpdir/unscoped-status-counts-zero-authoritative-step.md"
unscoped_status_counts_partial_fallback_summary="$tmpdir/unscoped-status-counts-partial-fallback.json"
unscoped_status_counts_partial_fallback_step_summary="$tmpdir/unscoped-status-counts-partial-fallback-step.md"
unscoped_partition_list_overlap_summary="$tmpdir/unscoped-partition-list-overlap.json"
unscoped_partition_list_overlap_step_summary="$tmpdir/unscoped-partition-list-overlap-step.md"
unscoped_partition_list_malformed_counts_summary="$tmpdir/unscoped-partition-list-malformed-counts.json"
unscoped_partition_list_malformed_counts_step_summary="$tmpdir/unscoped-partition-list-malformed-counts-step.md"
unscoped_explicit_empty_partition_lists_status_map_summary="$tmpdir/unscoped-explicit-empty-partition-lists-status-map.json"
unscoped_explicit_empty_partition_lists_status_map_step_summary="$tmpdir/unscoped-explicit-empty-partition-lists-status-map-step.md"
unscoped_executed_fallback_empty_status_map_summary="$tmpdir/unscoped-executed-fallback-empty-status-map.json"
unscoped_executed_fallback_empty_status_map_step_summary="$tmpdir/unscoped-executed-fallback-empty-status-map-step.md"
unscoped_executed_explicit_empty_list_summary="$tmpdir/unscoped-executed-explicit-empty-list.json"
unscoped_executed_explicit_empty_list_step_summary="$tmpdir/unscoped-executed-explicit-empty-list-step.md"
unscoped_executed_scalar_count_overrides_empty_list_summary="$tmpdir/unscoped-executed-scalar-count-overrides-empty-list.json"
unscoped_executed_scalar_count_overrides_empty_list_step_summary="$tmpdir/unscoped-executed-scalar-count-overrides-empty-list-step.md"
unscoped_executed_fallback_partial_status_map_summary="$tmpdir/unscoped-executed-fallback-partial-status-map.json"
unscoped_executed_fallback_partial_status_map_step_summary="$tmpdir/unscoped-executed-fallback-partial-status-map-step.md"
derived_status_map_summary="$tmpdir/derived-status-map.json"
derived_status_map_step_summary="$tmpdir/derived-status-map-step.md"
status_map_duplicate_keys_summary="$tmpdir/status-map-duplicate-keys.json"
status_map_duplicate_keys_step_summary="$tmpdir/status-map-duplicate-keys-step.md"
duplicate_normalized_map_keys_summary="$tmpdir/duplicate-normalized-map-keys.json"
duplicate_normalized_map_keys_step_summary="$tmpdir/duplicate-normalized-map-keys-step.md"
derived_dry_run_summary="$tmpdir/derived-dry-run.json"
derived_dry_run_step_summary="$tmpdir/derived-dry-run-step.md"
derived_continued_failure_summary="$tmpdir/derived-continued-failure.json"
derived_continued_failure_step_summary="$tmpdir/derived-continued-failure-step.md"
explicit_reason_summary="$tmpdir/explicit-reason.json"
explicit_reason_step_summary="$tmpdir/explicit-reason-step.md"
invalid_reason_summary="$tmpdir/invalid-reason.json"
invalid_reason_step_summary="$tmpdir/invalid-reason-step.md"
explicit_run_classification_summary="$tmpdir/explicit-run-classification.json"
explicit_run_classification_step_summary="$tmpdir/explicit-run-classification-step.md"
conflicting_reason_classification_summary="$tmpdir/conflicting-reason-classification.json"
conflicting_reason_classification_step_summary="$tmpdir/conflicting-reason-classification-step.md"
conflicting_run_state_flags_summary="$tmpdir/conflicting-run-state-flags.json"
conflicting_run_state_flags_step_summary="$tmpdir/conflicting-run-state-flags-step.md"
conflicting_classification_flags_summary="$tmpdir/conflicting-classification-flags.json"
conflicting_classification_flags_step_summary="$tmpdir/conflicting-classification-flags-step.md"
invalid_reason_with_classification_summary="$tmpdir/invalid-reason-with-classification.json"
invalid_reason_with_classification_step_summary="$tmpdir/invalid-reason-with-classification-step.md"
invalid_classification_with_reason_summary="$tmpdir/invalid-classification-with-reason.json"
invalid_classification_with_reason_step_summary="$tmpdir/invalid-classification-with-reason-step.md"
dry_run_reason_conflicts_summary="$tmpdir/dry-run-reason-conflicts.json"
dry_run_reason_conflicts_step_summary="$tmpdir/dry-run-reason-conflicts-step.md"
success_reason_conflicts_summary="$tmpdir/success-reason-conflicts.json"
success_reason_conflicts_step_summary="$tmpdir/success-reason-conflicts-step.md"
success_reason_explicit_continue_summary="$tmpdir/success-reason-explicit-continue.json"
success_reason_explicit_continue_step_summary="$tmpdir/success-reason-explicit-continue-step.md"
success_classification_explicit_continue_summary="$tmpdir/success-classification-explicit-continue.json"
success_classification_explicit_continue_step_summary="$tmpdir/success-classification-explicit-continue-step.md"
numeric_boolean_flags_summary="$tmpdir/numeric-boolean-flags.json"
numeric_boolean_flags_step_summary="$tmpdir/numeric-boolean-flags-step.md"
invalid_numeric_boolean_flags_summary="$tmpdir/invalid-numeric-boolean-flags.json"
invalid_numeric_boolean_flags_step_summary="$tmpdir/invalid-numeric-boolean-flags-step.md"
minimal_summary="$tmpdir/minimal.json"
minimal_step_summary="$tmpdir/minimal-step.md"
env_path_step_summary="$tmpdir/env-path-step.md"
scalar_summary="$tmpdir/scalar.json"
scalar_step_summary="$tmpdir/scalar-step.md"
append_step_summary="$tmpdir/append-step.md"
multiline_heading_step_summary="$tmpdir/multiline-heading-step.md"
blank_heading_step_summary="$tmpdir/blank-heading-step.md"
whitespace_heading_step_summary="$tmpdir/whitespace-heading-step.md"
array_summary="$tmpdir/array.json"
array_step_summary="$tmpdir/array-step.md"
null_summary="$tmpdir/null.json"
null_step_summary="$tmpdir/null-step.md"

expected_schema_version="$(sed -n 's/^SUMMARY_SCHEMA_VERSION=\([0-9][0-9]*\)$/\1/p' ./scripts/verify-gates.sh | awk 'NR==1{print;exit}')"
supported_schema_version="$(sed -n 's/^const supportedSchemaVersion = \([0-9][0-9]*\);$/\1/p' ./scripts/publish-verify-gates-summary.sh | awk 'NR==1{print;exit}')"

if [[ -z "$expected_schema_version" ]]; then
	echo "Unable to resolve SUMMARY_SCHEMA_VERSION from scripts/verify-gates.sh." >&2
	exit 1
fi

if [[ -z "$supported_schema_version" ]]; then
	echo "Unable to resolve supportedSchemaVersion from scripts/publish-verify-gates-summary.sh." >&2
	exit 1
fi

if [[ "$expected_schema_version" != "$supported_schema_version" ]]; then
	echo "Schema version mismatch: verify-gates=${expected_schema_version}, publish=${supported_schema_version}." >&2
	exit 1
fi

if ! grep -q "Current summary schema version: \`${expected_schema_version}\`." ./scripts/README.md; then
	echo "scripts/README.md summary schema version does not match ${expected_schema_version}." >&2
	exit 1
fi

if ! grep -q "./scripts/test-verify-gates-summary.sh" "./.github/workflows/pointer-quality.yml"; then
	echo "pointer-quality workflow is missing verify-gates summary contract step." >&2
	exit 1
fi

if ! grep -q "./scripts/test-verify-gates-summary.sh" "./.github/workflows/verify-gates-nightly.yml"; then
	echo "verify-gates-nightly workflow is missing verify-gates summary contract step." >&2
	exit 1
fi

VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$dry_summary" > "$tmpdir/dry.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$dry_repeat_summary" > "$tmpdir/dry-repeat.out"
VSCODE_VERIFY_CONTINUE_ON_FAILURE=true VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$continue_true_summary" > "$tmpdir/continue-true.out"
VSCODE_VERIFY_CONTINUE_ON_FAILURE=off VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$continue_false_summary" > "$tmpdir/continue-false.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --continue-on-failure --dry-run --summary-json "$continue_flag_summary" > "$tmpdir/continue-flag.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only " lint , lint , typecheck " --dry-run --summary-json "$dedupe_summary" > "$tmpdir/dedupe.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --from typecheck --dry-run --summary-json "$from_summary" > "$tmpdir/from.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --full --only build --dry-run --summary-json "$full_dry_summary" > "$tmpdir/full-dry.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --only build --dry-run --summary-json "$default_mode_dry_summary" > "$tmpdir/default-mode-dry.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" VSCODE_VERIFY_RETRIES=2 ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$env_retries_summary" > "$tmpdir/env-retries.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" VSCODE_VERIFY_RETRIES=2 ./scripts/verify-gates.sh --quick --only lint --retries 0 --dry-run --summary-json "$cli_retries_override_summary" > "$tmpdir/cli-retries-override.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --full --only build --dry-run --summary-json "$mode_precedence_full_summary" > "$tmpdir/mode-precedence-full.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --full --quick --only test-unit --dry-run --summary-json "$mode_precedence_quick_summary" > "$tmpdir/mode-precedence-quick.out"
if ! grep -q "Ignoring duplicate gate ids from --only: lint" "$tmpdir/dedupe.out"; then
	echo "Expected duplicate --only gate IDs warning message." >&2
	exit 1
fi

function make() {
	if [[ "$1" == "lint" ]]; then
		return 7
	fi
	if [[ "$1" == "typecheck" ]]; then
		return 0
	fi
	return 0
}
export -f make

set +e
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint,typecheck --retries 0 --summary-json "$fail_fast_summary" > "$tmpdir/fail-fast.out" 2>&1
fail_fast_status=$?
set -e
if [[ "$fail_fast_status" -ne 1 ]]; then
	echo "Expected fail-fast run to exit with code 1, got ${fail_fast_status}." >&2
	exit 1
fi

unset -f make

function make() {
	if [[ "$1" == "lint" ]]; then
		return 7
	fi
	if [[ "$1" == "typecheck" ]]; then
		return 0
	fi
	return 0
}
export -f make

set +e
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint,typecheck --continue-on-failure --retries 0 --summary-json "$continue_fail_summary" > "$tmpdir/continue-fail.out" 2>&1
continue_fail_status=$?
set -e
if [[ "$continue_fail_status" -ne 1 ]]; then
	echo "Expected continue-on-failure run with lint failure to exit with code 1, got ${continue_fail_status}." >&2
	exit 1
fi

unset -f make

function make() {
	if [[ "$1" == "lint" ]]; then
		return 7
	fi
	if [[ "$1" == "typecheck" ]]; then
		return 3
	fi
	return 0
}
export -f make

set +e
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint,typecheck --continue-on-failure --retries 0 --summary-json "$continue_multi_fail_summary" > "$tmpdir/continue-multi-fail.out" 2>&1
continue_multi_fail_status=$?
set -e
if [[ "$continue_multi_fail_status" -ne 1 ]]; then
	echo "Expected continue-on-failure run with multiple failures to exit with code 1, got ${continue_multi_fail_status}." >&2
	exit 1
fi

unset -f make

lint_attempt_file="$tmpdir/lint-attempt.txt"
echo "0" > "$lint_attempt_file"
function make() {
	if [[ "$1" == "lint" ]]; then
		attempt="$(<"$VERIFY_LINT_ATTEMPT_FILE")"
		attempt=$((attempt + 1))
		echo "$attempt" > "$VERIFY_LINT_ATTEMPT_FILE"
		if ((attempt == 1)); then
			return 4
		fi
		return 0
	fi
	if [[ "$1" == "typecheck" ]]; then
		return 0
	fi
	return 0
}
export -f make

VERIFY_LINT_ATTEMPT_FILE="$lint_attempt_file" VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint,typecheck --retries 1 --summary-json "$retry_summary" > "$tmpdir/retry.out"

unset -f make

GITHUB_STEP_SUMMARY="$fail_fast_step_summary" ./scripts/publish-verify-gates-summary.sh "$fail_fast_summary" "Verify Gates Fail-fast Contract Test"
GITHUB_STEP_SUMMARY="$retry_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "Verify Gates Retry Contract Test"
GITHUB_STEP_SUMMARY="$continue_flag_step_summary" ./scripts/publish-verify-gates-summary.sh "$continue_flag_summary" "Verify Gates Continue-on-Failure Dry-Run Contract Test"
GITHUB_STEP_SUMMARY="$continue_fail_step_summary" ./scripts/publish-verify-gates-summary.sh "$continue_fail_summary" "Verify Gates Continue-on-Failure Failure Contract Test"
GITHUB_STEP_SUMMARY="$continue_multi_fail_step_summary" ./scripts/publish-verify-gates-summary.sh "$continue_multi_fail_summary" "Verify Gates Continue-on-Failure Multi-Failure Contract Test"

node - "$retry_summary" "$fallback_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, fallbackPath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
delete payload.gateStatusById;
delete payload.gateExitCodeById;
delete payload.gateRetryCountById;
delete payload.gateDurationSecondsById;
delete payload.gateNotRunReasonById;
delete payload.gateAttemptCountById;
delete payload.attentionGateIds;
delete payload.nonSuccessGateIds;
delete payload.notRunGateIds;
delete payload.failedGateIds;
delete payload.failedGateExitCodes;
delete payload.passedGateIds;
delete payload.skippedGateIds;
delete payload.executedGateIds;
delete payload.retriedGateIds;
delete payload.selectedGateIds;
fs.writeFileSync(fallbackPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$fallback_summary" "Verify Gates Fallback Contract Test"

node - "$dry_summary" "$dry_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, fallbackPath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
delete payload.gateExitCodeById;
fs.writeFileSync(fallbackPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$dry_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$dry_fallback_summary" "Verify Gates Dry Fallback Contract Test"

node - "$fail_fast_summary" "$fail_fast_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, fallbackPath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
delete payload.gateExitCodeById;
fs.writeFileSync(fallbackPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$fail_fast_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$fail_fast_fallback_summary" "Verify Gates Fail-fast Fallback Contract Test"

node - "$expected_schema_version" "$derived_counts_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-counts-contract',
	gates: [
		{ id: ' lint ', command: 'make lint', status: ' PASS ', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: ' 20260215T010000Z ', completedAt: ' 20260215T010001Z ', notRunReason: null },
		{ id: ' typecheck ', command: 'make typecheck', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 2, exitCode: 2, startedAt: ' 20260215T010001Z ', completedAt: ' 20260215T010003Z ', notRunReason: null },
		{ id: ' test-unit ', command: 'make test-unit', status: 'Skip', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: '20260215T010003Z', completedAt: '20260215T010003Z', notRunReason: null },
		{ id: ' build ', command: 'make build', status: ' Not-Run ', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: '  blocked-by-fail-fast:typecheck  ' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_counts_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_counts_summary" "Verify Gates Derived Count Fallback Contract Test"

node - "$expected_schema_version" "$duplicate_gate_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'duplicate-gate-rows-contract',
	gates: [
		{ id: ' lint ', command: 'make lint', status: ' fail ', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 9, startedAt: '20260215T020000Z', completedAt: '20260215T020001Z', notRunReason: null },
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T020001Z', completedAt: '20260215T020002Z', notRunReason: null },
		{ id: ' typecheck ', command: 'make typecheck', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 2, exitCode: 2, startedAt: '20260215T020002Z', completedAt: '20260215T020004Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$duplicate_gate_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$duplicate_gate_rows_summary" "Verify Gates Duplicate Gate Rows Contract Test"

node - "$expected_schema_version" "$malformed_gate_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'malformed-gate-rows-contract',
	gates: [
		null,
		'not-an-object',
		42,
		{ id: ' lint ', command: 'make lint', status: ' PASS ', attempts: '1', retryCount: '0', retryBackoffSeconds: '0', durationSeconds: '1', exitCode: '0', startedAt: '20260215T030000Z', completedAt: '20260215T030001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$malformed_gate_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$malformed_gate_rows_summary" "Verify Gates Malformed Gate Rows Contract Test"

node - "$expected_schema_version" "$row_not_run_reason_type_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'row-not-run-reason-type-contract',
	gates: [
		{ id: ' build ', command: 'make build', status: ' Not-Run ', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 7 },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$row_not_run_reason_type_step_summary" ./scripts/publish-verify-gates-summary.sh "$row_not_run_reason_type_summary" "Verify Gates Row Not-Run Reason Type Contract Test"

node - "$expected_schema_version" "$row_command_type_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'row-command-type-contract',
	gates: [
		{ id: ' lint ', command: 9, status: 'PASS', attempts: 'bad', retryCount: -1, retryBackoffSeconds: 'oops', durationSeconds: 'bad', exitCode: -1, startedAt: '20260215T040000Z', completedAt: '20260215T040001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$row_command_type_step_summary" ./scripts/publish-verify-gates-summary.sh "$row_command_type_summary" "Verify Gates Row Command Type Contract Test"

node - "$expected_schema_version" "$unknown_status_duplicate_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unknown-status-duplicate-rows-contract',
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'PASS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T050000Z', completedAt: '20260215T050001Z', notRunReason: null },
		{ id: 'lint', command: 'make lint', status: 'mystery-status', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T050001Z', completedAt: '20260215T050002Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unknown_status_duplicate_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$unknown_status_duplicate_rows_summary" "Verify Gates Unknown Status Duplicate Rows Contract Test"

node - "$expected_schema_version" "$unknown_status_only_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unknown-status-only-rows-contract',
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'mystery-status', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T060000Z', completedAt: '20260215T060001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unknown_status_only_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$unknown_status_only_rows_summary" "Verify Gates Unknown Status Only Rows Contract Test"

node - "$expected_schema_version" "$duplicate_same_status_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'duplicate-same-status-rows-contract',
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 3, startedAt: '20260215T070000Z', completedAt: '20260215T070001Z', notRunReason: null },
		{ id: 'lint', command: 'make lint', status: 'fail', attempts: 2, retryCount: 1, retryBackoffSeconds: 1, durationSeconds: 2, exitCode: 7, startedAt: '20260215T070001Z', completedAt: '20260215T070003Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$duplicate_same_status_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$duplicate_same_status_rows_summary" "Verify Gates Duplicate Same-Status Rows Contract Test"

node - "$expected_schema_version" "$selected_order_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-order-rows-contract',
	selectedGateIds: [' build ', 'lint', '', 7, 'build'],
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'PASS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T080000Z', completedAt: '20260215T080001Z', notRunReason: null },
		{ id: ' build ', command: 'make build', status: 'PASS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T080001Z', completedAt: '20260215T080002Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_order_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_order_rows_summary" "Verify Gates Selected Order Rows Contract Test"

node - "$expected_schema_version" "$selected_order_missing_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-order-missing-rows-contract',
	selectedGateIds: ['missing', 'lint'],
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'PASS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T080000Z', completedAt: '20260215T080001Z', notRunReason: null },
		{ id: ' build ', command: 'make build', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 8, startedAt: '20260215T080001Z', completedAt: '20260215T080002Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_order_missing_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_order_missing_rows_summary" "Verify Gates Selected Order Missing Rows Contract Test"

node - "$expected_schema_version" "$selected_order_unmatched_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-order-unmatched-rows-contract',
	selectedGateIds: ['missing-only'],
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'PASS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T080000Z', completedAt: '20260215T080001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_order_unmatched_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_order_unmatched_rows_summary" "Verify Gates Selected Order Unmatched Rows Contract Test"

node - "$expected_schema_version" "$selected_subset_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-subset-rows-contract',
	selectedGateIds: ['lint'],
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'PASS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T080000Z', completedAt: '20260215T080001Z', notRunReason: null },
		{ id: ' build ', command: 'make build', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 9, startedAt: '20260215T080001Z', completedAt: '20260215T080002Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_subset_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_subset_rows_summary" "Verify Gates Selected Subset Rows Contract Test"

node - "$expected_schema_version" "$selected_empty_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-empty-rows-contract',
	selectedGateIds: [],
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'PASS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T080000Z', completedAt: '20260215T080001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_empty_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_empty_rows_summary" "Verify Gates Selected Empty Rows Contract Test"

node - "$expected_schema_version" "$invocation_whitespace_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'invocation-whitespace-contract',
	invocation: '   ',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invocation_whitespace_step_summary" ./scripts/publish-verify-gates-summary.sh "$invocation_whitespace_summary" "Verify Gates Invocation Whitespace Contract Test"

node - "$expected_schema_version" "$metadata_whitespace_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: '   ',
	resultSignatureAlgorithm: '   ',
	resultSignature: '   ',
	slowestExecutedGateId: '   ',
	slowestExecutedGateDurationSeconds: 'bad',
	fastestExecutedGateId: '   ',
	fastestExecutedGateDurationSeconds: '-1',
	logFile: '   ',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$metadata_whitespace_step_summary" ./scripts/publish-verify-gates-summary.sh "$metadata_whitespace_summary" "Verify Gates Metadata Whitespace Contract Test"

node - "$expected_schema_version" "$metadata_nonstring_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 123,
	resultSignatureAlgorithm: 9,
	resultSignature: false,
	logFile: 42,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$metadata_nonstring_step_summary" ./scripts/publish-verify-gates-summary.sh "$metadata_nonstring_summary" "Verify Gates Metadata Nonstring Contract Test"

node - "$expected_schema_version" "$slow_fast_string_metadata_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	slowestExecutedGateId: ' lint ',
	slowestExecutedGateDurationSeconds: '5',
	fastestExecutedGateId: ' typecheck ',
	fastestExecutedGateDurationSeconds: '1',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$slow_fast_string_metadata_step_summary" ./scripts/publish-verify-gates-summary.sh "$slow_fast_string_metadata_summary" "Verify Gates Slow/Fast String Metadata Contract Test"

node - "$expected_schema_version" "$slow_fast_none_sentinel_metadata_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	slowestExecutedGateId: ' none ',
	slowestExecutedGateDurationSeconds: '5',
	fastestExecutedGateId: ' NoNe ',
	fastestExecutedGateDurationSeconds: '1',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$slow_fast_none_sentinel_metadata_step_summary" ./scripts/publish-verify-gates-summary.sh "$slow_fast_none_sentinel_metadata_summary" "Verify Gates Slow/Fast None Sentinel Metadata Contract Test"

node - "$expected_schema_version" "$explicit_empty_attention_lists_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-empty-attention-lists-contract',
	nonSuccessGateIds: [],
	attentionGateIds: [],
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 2, startedAt: '20260215T090000Z', completedAt: '20260215T090001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_empty_attention_lists_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_empty_attention_lists_summary" "Verify Gates Explicit Empty Attention Lists Contract Test"

node - "$expected_schema_version" "$explicit_empty_non_success_with_retries_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-empty-non-success-with-retries-contract',
	gateStatusById: { lint: 'pass', build: 'pass' },
	nonSuccessGateIds: [],
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 2, build: 0 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_empty_non_success_with_retries_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_empty_non_success_with_retries_summary" "Verify Gates Explicit Empty Non-Success With Retries Contract Test"

node - "$expected_schema_version" "$explicit_empty_attention_with_retries_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-empty-attention-with-retries-contract',
	gateStatusById: { lint: 'pass', build: 'pass' },
	attentionGateIds: [],
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 2, build: 0 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_empty_attention_with_retries_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_empty_attention_with_retries_summary" "Verify Gates Explicit Empty Attention With Retries Contract Test"

node - "$expected_schema_version" "$selected_status_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-map-scope-contract',
	selectedGateIds: [' lint '],
	gateStatusById: { ' lint ': ' PASS ', ' build ': ' fail ' },
	gateExitCodeById: { lint: 0, build: 9 },
	gateRetryCountById: { lint: 0, build: 3 },
	gateDurationSecondsById: { lint: 1, build: 8 },
	gateAttemptCountById: { lint: 1, build: 4 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_map_scope_summary" "Verify Gates Selected Status-Map Scope Contract Test"

node - "$expected_schema_version" "$selected_status_counts_conflict_status_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-counts-conflict-status-map-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	passedGateCount: 8,
	failedGateCount: 7,
	skippedGateCount: 6,
	notRunGateCount: 5,
	executedGateCount: 4,
	statusCounts: { pass: 9, fail: 8, skip: 7, 'not-run': 6 },
	gateStatusById: { lint: 'pass', typecheck: 'fail' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_counts_conflict_status_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_counts_conflict_status_map_scope_summary" "Verify Gates Selected Status Counts Conflict Status-Map Scope Contract Test"

node - "$expected_schema_version" "$selected_status_counts_partial_malformed_status_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-counts-partial-malformed-status-map-scope-contract',
	selectedGateIds: ['lint', 'typecheck', 'docs'],
	passedGateCount: 8,
	failedGateCount: 'bad',
	skippedGateCount: 6,
	notRunGateCount: -1,
	executedGateCount: 7,
	statusCounts: { pass: 'bad', fail: 9, skip: null, 'not-run': '2' },
	gateStatusById: { lint: 'pass', typecheck: 'fail', docs: 'not-run' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_counts_partial_malformed_status_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_counts_partial_malformed_status_map_scope_summary" "Verify Gates Selected Status Counts Partial Malformed Status-Map Scope Contract Test"

node - "$expected_schema_version" "$selected_status_counts_zero_raw_status_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-counts-zero-raw-status-map-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	passedGateCount: 0,
	failedGateCount: 0,
	skippedGateCount: 0,
	notRunGateCount: 0,
	executedGateCount: 0,
	statusCounts: { pass: 0, fail: '0', skip: 0, 'not-run': 0 },
	gateStatusById: { lint: 'pass', typecheck: 'fail' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_counts_zero_raw_status_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_counts_zero_raw_status_map_scope_summary" "Verify Gates Selected Status Counts Zero Raw Status-Map Scope Contract Test"

node - "$expected_schema_version" "$selected_status_counts_partial_status_map_partition_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-counts-partial-status-map-partition-scope-contract',
	selectedGateIds: ['lint', 'typecheck', 'build'],
	passedGateCount: 6,
	failedGateCount: 5,
	skippedGateCount: 4,
	notRunGateCount: 3,
	executedGateCount: 2,
	statusCounts: { pass: 9, fail: 'bad', skip: 8, 'not-run': 7 },
	gateStatusById: { lint: 'pass', ' typecheck ': 'unknown', build: 'pending' },
	failedGateIds: ['typecheck'],
	notRunGateIds: ['build'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_counts_partial_status_map_partition_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_counts_partial_status_map_partition_scope_summary" "Verify Gates Selected Status Counts Partial Status-Map Partition Scope Contract Test"

node - "$expected_schema_version" "$selected_scalar_failure_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-scalar-failure-scope-contract',
	selectedGateIds: ['lint'],
	passedGateIds: ['lint'],
	failedGateIds: ['build'],
	failedGateExitCodes: [9],
	failedGateId: 'build',
	failedGateExitCode: 9,
	blockedByGateId: 'build',
	gateNotRunReasonById: { lint: null, build: 'blocked-by-fail-fast:build' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_scalar_failure_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_scalar_failure_scope_summary" "Verify Gates Selected Scalar Failure Scope Contract Test"

node - "$expected_schema_version" "$selected_scalar_counts_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-scalar-counts-scope-contract',
	selectedGateIds: ['lint'],
	gateCount: 9,
	passedGateCount: 0,
	failedGateCount: 5,
	skippedGateCount: 2,
	notRunGateCount: 2,
	executedGateCount: 5,
	statusCounts: { pass: 0, fail: 5, skip: 2, 'not-run': 2 },
	gateStatusById: { lint: 'pass' },
	gateDurationSecondsById: { lint: 1 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_scalar_counts_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_scalar_counts_scope_summary" "Verify Gates Selected Scalar Counts Scope Contract Test"

node - "$expected_schema_version" "$selected_status_counts_no_evidence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-counts-no-evidence-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	gateCount: 9,
	passedGateCount: 8,
	failedGateCount: 7,
	skippedGateCount: 6,
	notRunGateCount: 5,
	executedGateCount: 4,
	statusCounts: { pass: 3, fail: 2, skip: 1, 'not-run': 0 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_counts_no_evidence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_counts_no_evidence_scope_summary" "Verify Gates Selected Status Counts No Evidence Scope Contract Test"

node - "$expected_schema_version" "$selected_status_counts_conflict_partition_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-counts-conflict-partition-scope-contract',
	selectedGateIds: ['lint', 'typecheck', 'build', 'deploy'],
	statusCounts: { pass: 9, fail: 8, skip: 7, 'not-run': 6 },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_counts_conflict_partition_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_counts_conflict_partition_scope_summary" "Verify Gates Selected Status Counts Conflict Partition Scope Contract Test"

node - "$expected_schema_version" "$selected_scalar_raw_count_mix_partition_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-scalar-raw-count-mix-partition-scope-contract',
	selectedGateIds: ['lint', 'typecheck', 'build', 'deploy'],
	gateCount: 99,
	passedGateCount: 12,
	failedGateCount: 'bad',
	skippedGateCount: 8,
	notRunGateCount: -1,
	executedGateCount: 55,
	statusCounts: { pass: 10, fail: 9, skip: 'x', 'not-run': 7 },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_scalar_raw_count_mix_partition_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_scalar_raw_count_mix_partition_scope_summary" "Verify Gates Selected Scalar Raw Count Mix Partition Scope Contract Test"

node - "$expected_schema_version" "$selected_status_counts_partial_malformed_partition_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-counts-partial-malformed-partition-scope-contract',
	selectedGateIds: ['lint', 'typecheck', 'build', 'deploy'],
	statusCounts: { pass: 'bad', fail: 9, skip: null, 'not-run': '1.5' },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_counts_partial_malformed_partition_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_counts_partial_malformed_partition_scope_summary" "Verify Gates Selected Status Counts Partial Malformed Partition Scope Contract Test"

node - "$expected_schema_version" "$selected_status_counts_zero_raw_partition_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-status-counts-zero-raw-partition-scope-contract',
	selectedGateIds: ['lint', 'typecheck', 'build', 'deploy'],
	statusCounts: { pass: 0, fail: '0', skip: 0, 'not-run': 0 },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_status_counts_zero_raw_partition_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_status_counts_zero_raw_partition_scope_summary" "Verify Gates Selected Status Counts Zero Raw Partition Scope Contract Test"

node - "$expected_schema_version" "$selected_failed_exit_code_alignment_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-failed-exit-code-alignment-contract',
	selectedGateIds: ['lint'],
	failedGateIds: ['build', 'lint'],
	failedGateExitCodes: [9, 2],
	gateStatusById: { lint: 'fail' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_failed_exit_code_alignment_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_failed_exit_code_alignment_summary" "Verify Gates Selected Failed Exit-Code Alignment Contract Test"

node - "$expected_schema_version" "$selected_slow_fast_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-slow-fast-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateDurationSecondsById: { lint: 3 },
	slowestExecutedGateId: 'build',
	slowestExecutedGateDurationSeconds: 9,
	fastestExecutedGateId: 'build',
	fastestExecutedGateDurationSeconds: 1,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_slow_fast_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_slow_fast_scope_summary" "Verify Gates Selected Slow/Fast Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 0 },
	gateDurationSecondsById: { lint: 4 },
	retriedGateCount: 8,
	totalRetryCount: 8,
	totalRetryBackoffSeconds: 8,
	executedDurationSeconds: 99,
	averageExecutedDurationSeconds: 99,
	retryRatePercent: 80,
	retryBackoffSharePercent: 80,
	passRatePercent: 0,
	totalDurationSeconds: 200,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_scope_summary" "Verify Gates Selected Aggregate Metrics Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_string_scalar_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-string-scalar-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retriedGateCount: ' 8 ',
	totalRetryCount: ' 8 ',
	totalRetryBackoffSeconds: ' 8 ',
	executedDurationSeconds: ' 99 ',
	averageExecutedDurationSeconds: ' 99 ',
	retryRatePercent: ' 80 ',
	retryBackoffSharePercent: ' 80 ',
	passRatePercent: ' 0 ',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_string_scalar_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_string_scalar_scope_summary" "Verify Gates Selected Aggregate Metrics String Scalar Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_decimal_string_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-decimal-string-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retriedGateCount: '8.5',
	totalRetryCount: '8.5',
	totalRetryBackoffSeconds: '8.5',
	executedDurationSeconds: '99.5',
	averageExecutedDurationSeconds: '99.5',
	retryRatePercent: '80.5',
	retryBackoffSharePercent: '80.5',
	passRatePercent: '0.5',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_decimal_string_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_decimal_string_scope_summary" "Verify Gates Selected Aggregate Metrics Decimal String Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_scientific_string_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-scientific-string-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retriedGateCount: '8e1',
	totalRetryCount: '8e1',
	totalRetryBackoffSeconds: '8e1',
	executedDurationSeconds: '99e1',
	averageExecutedDurationSeconds: '99e1',
	retryRatePercent: '80e1',
	retryBackoffSharePercent: '80e1',
	passRatePercent: '0e1',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_scientific_string_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_scientific_string_scope_summary" "Verify Gates Selected Aggregate Metrics Scientific String Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_float_scalar_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-float-scalar-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retriedGateCount: 8.5,
	totalRetryCount: 8.5,
	totalRetryBackoffSeconds: 8.5,
	executedDurationSeconds: 99.5,
	averageExecutedDurationSeconds: 99.5,
	retryRatePercent: 80.5,
	retryBackoffSharePercent: 80.5,
	passRatePercent: 0.5,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_float_scalar_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_float_scalar_scope_summary" "Verify Gates Selected Aggregate Metrics Float Scalar Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_rate_scalar_overflow_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-rate-scalar-overflow-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retryRatePercent: 150,
	retryBackoffSharePercent: 140,
	passRatePercent: 120,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_rate_scalar_overflow_scope_summary" "Verify Gates Selected Aggregate Metrics Rate Scalar Overflow Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_rate_scalar_boundary_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-rate-scalar-boundary-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retryRatePercent: 0,
	retryBackoffSharePercent: 0,
	passRatePercent: 0,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_rate_scalar_boundary_scope_summary" "Verify Gates Selected Aggregate Metrics Rate Scalar Boundary Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-rate-scalar-mixed-boundary-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retryRatePercent: 0,
	retryBackoffSharePercent: 101,
	passRatePercent: 100,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_summary" "Verify Gates Selected Aggregate Metrics Rate Scalar Mixed Boundary Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_malformed_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-malformed-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retriedGateCount: 'bad',
	totalRetryCount: 'bad',
	totalRetryBackoffSeconds: 'bad',
	executedDurationSeconds: 'bad',
	averageExecutedDurationSeconds: 'bad',
	retryRatePercent: 'bad',
	retryBackoffSharePercent: 'bad',
	passRatePercent: 'bad',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_malformed_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_malformed_scope_summary" "Verify Gates Selected Aggregate Metrics Malformed Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_no_evidence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-no-evidence-scope-contract',
	selectedGateIds: ['lint'],
	retriedGateCount: 8,
	totalRetryCount: 8,
	totalRetryBackoffSeconds: 8,
	executedDurationSeconds: 99,
	averageExecutedDurationSeconds: 99,
	retryRatePercent: 80,
	retryBackoffSharePercent: 80,
	passRatePercent: 0,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_no_evidence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_no_evidence_scope_summary" "Verify Gates Selected Aggregate Metrics No Evidence Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-rate-scalar-overflow-no-evidence-scope-contract',
	selectedGateIds: ['lint'],
	retryRatePercent: 150,
	retryBackoffSharePercent: 140,
	passRatePercent: 120,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_summary" "Verify Gates Selected Aggregate Metrics Rate Scalar Overflow No Evidence Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-scope-contract',
	selectedGateIds: ['lint'],
	retryRatePercent: 100,
	retryBackoffSharePercent: 101,
	passRatePercent: 0,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_summary" "Verify Gates Selected Aggregate Metrics Rate Scalar Mixed Boundary No Evidence Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-string-scope-contract',
	selectedGateIds: ['lint'],
	retryRatePercent: ' 100 ',
	retryBackoffSharePercent: '101',
	passRatePercent: ' 0 ',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_summary" "Verify Gates Selected Aggregate Metrics Rate Scalar Mixed Boundary No Evidence String Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_nonselected_evidence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-nonselected-evidence-scope-contract',
	selectedGateIds: ['lint'],
	executedGateIds: ['build'],
	retriedGateIds: ['build'],
	passedGateIds: ['build'],
	gateStatusById: { build: 'pass' },
	gateRetryCountById: { build: 2 },
	gateDurationSecondsById: { build: 5 },
	retriedGateCount: 8,
	totalRetryCount: 8,
	totalRetryBackoffSeconds: 8,
	executedDurationSeconds: 99,
	averageExecutedDurationSeconds: 99,
	retryRatePercent: 80,
	retryBackoffSharePercent: 80,
	passRatePercent: 0,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_nonselected_evidence_scope_summary" "Verify Gates Selected Aggregate Metrics Nonselected Evidence Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_no_evidence_string_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-no-evidence-string-scope-contract',
	selectedGateIds: ['lint'],
	retriedGateCount: '8',
	totalRetryCount: '8',
	totalRetryBackoffSeconds: '8',
	executedDurationSeconds: '99',
	averageExecutedDurationSeconds: '99',
	retryRatePercent: '80',
	retryBackoffSharePercent: '80',
	passRatePercent: '0',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_no_evidence_string_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_no_evidence_string_scope_summary" "Verify Gates Selected Aggregate Metrics No Evidence String Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_no_evidence_plus_string_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-no-evidence-plus-string-scope-contract',
	selectedGateIds: ['lint'],
	retriedGateCount: '+8',
	totalRetryCount: '+8',
	totalRetryBackoffSeconds: '+8',
	executedDurationSeconds: '+99',
	averageExecutedDurationSeconds: '+99',
	retryRatePercent: '+80',
	retryBackoffSharePercent: '+80',
	passRatePercent: '+0',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_no_evidence_plus_string_scope_summary" "Verify Gates Selected Aggregate Metrics No Evidence Plus String Scope Contract Test"

node - "$expected_schema_version" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-aggregate-metrics-no-evidence-mixed-invalid-scope-contract',
	selectedGateIds: ['lint'],
	retriedGateCount: '8.5',
	totalRetryCount: '8e1',
	totalRetryBackoffSeconds: 8.5,
	executedDurationSeconds: '99.5',
	averageExecutedDurationSeconds: '99e1',
	retryRatePercent: 80.5,
	retryBackoffSharePercent: '80e1',
	passRatePercent: -1,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_summary" "Verify Gates Selected Aggregate Metrics No Evidence Mixed Invalid Scope Contract Test"

node - "$expected_schema_version" "$selected_failed_exit_codes_without_ids_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-failed-exit-codes-without-ids-scope-contract',
	selectedGateIds: ['lint'],
	failedGateExitCodes: [9],
	gateStatusById: { lint: 'fail' },
	gateExitCodeById: { lint: 2 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_failed_exit_codes_without_ids_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_failed_exit_codes_without_ids_scope_summary" "Verify Gates Selected Failed Exit-Codes Without IDs Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20250101T000000Z',
	completedAt: '20250101T000010Z',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 3, exitCode: 0, startedAt: '20260215T100000Z', completedAt: '20260215T100003Z', notRunReason: null },
		{ id: 'build', command: 'make build', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 8, exitCode: 0, startedAt: '20260215T090000Z', completedAt: '20260215T090008Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_scope_summary" "Verify Gates Selected Timestamps Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260215T110000Z',
	completedAt: '20260215T110005Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_no_rows_scope_summary" "Verify Gates Selected Timestamps No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_invalid_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-invalid-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260230T110000Z',
	completedAt: '20260230T110005Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_invalid_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_invalid_no_rows_scope_summary" "Verify Gates Selected Timestamps Invalid No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_leap_valid_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-leap-valid-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20240229T110000Z',
	completedAt: '20240229T110005Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_leap_valid_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_leap_valid_no_rows_scope_summary" "Verify Gates Selected Timestamps Leap Valid No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_nonleap_century_invalid_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-nonleap-century-invalid-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '19000229T110000Z',
	completedAt: '19000229T110005Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_nonleap_century_invalid_no_rows_scope_summary" "Verify Gates Selected Timestamps Nonleap Century Invalid No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_century_leap_valid_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-century-leap-valid-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20000229T110000Z',
	completedAt: '20000229T110005Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_century_leap_valid_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_century_leap_valid_no_rows_scope_summary" "Verify Gates Selected Timestamps Century Leap Valid No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_invalid_second_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-invalid-second-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260215T110060Z',
	completedAt: '20260215T110065Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_invalid_second_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_invalid_second_no_rows_scope_summary" "Verify Gates Selected Timestamps Invalid Second No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_invalid_hour_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-invalid-hour-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260215T240000Z',
	completedAt: '20260215T240005Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_invalid_hour_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_invalid_hour_no_rows_scope_summary" "Verify Gates Selected Timestamps Invalid Hour No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_invalid_minute_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-invalid-minute-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260215T116000Z',
	completedAt: '20260215T116005Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_invalid_minute_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_invalid_minute_no_rows_scope_summary" "Verify Gates Selected Timestamps Invalid Minute No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_year_boundary_valid_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-year-boundary-valid-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20261231T235959Z',
	completedAt: '20270101T000004Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_year_boundary_valid_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_year_boundary_valid_no_rows_scope_summary" "Verify Gates Selected Timestamps Year Boundary Valid No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_day_boundary_valid_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-day-boundary-valid-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260228T235959Z',
	completedAt: '20260301T000004Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_day_boundary_valid_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_day_boundary_valid_no_rows_scope_summary" "Verify Gates Selected Timestamps Day Boundary Valid No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_whitespace_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-whitespace-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: ' 20260215T111500Z ',
	completedAt: '\t20260215T111505Z\t',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_whitespace_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_whitespace_no_rows_scope_summary" "Verify Gates Selected Timestamps Whitespace No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_conflicting_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-conflicting-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260215T130010Z',
	completedAt: '20260215T130000Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_conflicting_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_conflicting_no_rows_scope_summary" "Verify Gates Selected Timestamps Conflicting No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_unmatched_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-unmatched-rows-scope-contract',
	selectedGateIds: ['missing-only'],
	startedAt: '20260215T120000Z',
	completedAt: '20260215T120005Z',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T140000Z', completedAt: '20260215T140001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_unmatched_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_unmatched_rows_scope_summary" "Verify Gates Selected Timestamps Unmatched Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-unmatched-rows-malformed-explicit-scope-contract',
	selectedGateIds: ['missing-only'],
	startedAt: '20260230T120000Z',
	completedAt: '20260230T120005Z',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T140000Z', completedAt: '20260215T140001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_unmatched_rows_malformed_explicit_scope_summary" "Verify Gates Selected Timestamps Unmatched Rows Malformed Explicit Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_malformed_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-malformed-rows-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	gates: [
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 3, exitCode: 0, startedAt: '20260001T000000Z', completedAt: '20260001T000003Z', notRunReason: null },
		{ id: 'typecheck', command: 'make typecheck', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 4, exitCode: 0, startedAt: '20260215T100000Z', completedAt: '20260215T100004Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_malformed_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_malformed_rows_scope_summary" "Verify Gates Selected Timestamps Malformed Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_timestamps_malformed_rows_explicit_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-timestamps-malformed-rows-explicit-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260215T160000Z',
	completedAt: '20260215T160005Z',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 3, exitCode: 0, startedAt: '20260230T160000Z', completedAt: '20260230T160003Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_timestamps_malformed_rows_explicit_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_timestamps_malformed_rows_explicit_scope_summary" "Verify Gates Selected Timestamps Malformed Rows Explicit Scope Contract Test"

node - "$expected_schema_version" "$selected_duration_zero_map_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-duration-zero-map-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	gateDurationSecondsById: { lint: 0 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_duration_zero_map_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_duration_zero_map_no_rows_scope_summary" "Verify Gates Selected Duration Zero Map No Rows Scope Contract Test"

node - "$expected_schema_version" "$timestamps_malformed_explicit_unscoped_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'timestamps-malformed-explicit-unscoped-contract',
	startedAt: '20260230T170000Z',
	completedAt: '20260230T170005Z',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 2, exitCode: 0, startedAt: '20260215T170000Z', completedAt: '20260215T170002Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$timestamps_malformed_explicit_unscoped_step_summary" ./scripts/publish-verify-gates-summary.sh "$timestamps_malformed_explicit_unscoped_summary" "Verify Gates Timestamps Malformed Explicit Unscoped Contract Test"

node - "$expected_schema_version" "$timestamps_invalid_explicit_no_rows_unscoped_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'timestamps-invalid-explicit-no-rows-unscoped-contract',
	startedAt: '20260230T180000Z',
	completedAt: '20260230T180005Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$timestamps_invalid_explicit_no_rows_unscoped_step_summary" ./scripts/publish-verify-gates-summary.sh "$timestamps_invalid_explicit_no_rows_unscoped_summary" "Verify Gates Timestamps Invalid Explicit No Rows Unscoped Contract Test"

node - "$expected_schema_version" "$timestamps_whitespace_no_rows_unscoped_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'timestamps-whitespace-no-rows-unscoped-contract',
	startedAt: ' 20260215T181500Z ',
	completedAt: '\t20260215T181505Z\t',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$timestamps_whitespace_no_rows_unscoped_step_summary" ./scripts/publish-verify-gates-summary.sh "$timestamps_whitespace_no_rows_unscoped_summary" "Verify Gates Timestamps Whitespace No Rows Unscoped Contract Test"

node - "$expected_schema_version" "$timestamps_conflicting_no_rows_unscoped_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'timestamps-conflicting-no-rows-unscoped-contract',
	startedAt: '20260215T190010Z',
	completedAt: '20260215T190000Z',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$timestamps_conflicting_no_rows_unscoped_step_summary" ./scripts/publish-verify-gates-summary.sh "$timestamps_conflicting_no_rows_unscoped_summary" "Verify Gates Timestamps Conflicting No Rows Unscoped Contract Test"

node - "$expected_schema_version" "$timestamps_conflicting_no_rows_with_explicit_total_unscoped_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'timestamps-conflicting-no-rows-with-explicit-total-unscoped-contract',
	startedAt: '20260215T190010Z',
	completedAt: '20260215T190000Z',
	totalDurationSeconds: 9,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$timestamps_conflicting_no_rows_with_explicit_total_unscoped_step_summary" ./scripts/publish-verify-gates-summary.sh "$timestamps_conflicting_no_rows_with_explicit_total_unscoped_summary" "Verify Gates Timestamps Conflicting No Rows With Explicit Total Unscoped Contract Test"

node - "$expected_schema_version" "$total_duration_conflict_duration_map_no_rows_unscoped_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'total-duration-conflict-duration-map-no-rows-unscoped-contract',
	totalDurationSeconds: 7,
	gateDurationSecondsById: { lint: 3 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$total_duration_conflict_duration_map_no_rows_unscoped_step_summary" ./scripts/publish-verify-gates-summary.sh "$total_duration_conflict_duration_map_no_rows_unscoped_summary" "Verify Gates Total Duration Conflict Duration Map No Rows Unscoped Contract Test"

node - "$expected_schema_version" "$selected_total_duration_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-total-duration-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	totalDurationSeconds: 7,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_total_duration_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_total_duration_no_rows_scope_summary" "Verify Gates Selected Total Duration No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_total_duration_conflict_duration_map_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-total-duration-conflict-duration-map-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	totalDurationSeconds: 7,
	gateDurationSecondsById: { lint: 3 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_total_duration_conflict_duration_map_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_total_duration_conflict_duration_map_no_rows_scope_summary" "Verify Gates Selected Total Duration Conflict Duration Map No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_total_duration_conflict_zero_duration_map_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-total-duration-conflict-zero-duration-map-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	totalDurationSeconds: 7,
	gateDurationSecondsById: { lint: 0 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_total_duration_conflict_zero_duration_map_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_total_duration_conflict_zero_duration_map_no_rows_scope_summary" "Verify Gates Selected Total Duration Conflict Zero Duration Map No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_total_duration_nonselected_duration_map_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-total-duration-nonselected-duration-map-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	totalDurationSeconds: 7,
	gateDurationSecondsById: { build: 3 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_total_duration_nonselected_duration_map_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_total_duration_nonselected_duration_map_no_rows_scope_summary" "Verify Gates Selected Total Duration Nonselected Duration Map No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-total-duration-nonselected-duration-map-without-explicit-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	gateDurationSecondsById: { build: 3 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_summary" "Verify Gates Selected Total Duration Nonselected Duration Map Without Explicit No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_total_duration_conflicting_timestamps_no_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-total-duration-conflicting-timestamps-no-rows-scope-contract',
	selectedGateIds: ['lint'],
	startedAt: '20260215T190010Z',
	completedAt: '20260215T190000Z',
	totalDurationSeconds: 9,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_total_duration_conflicting_timestamps_no_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_total_duration_conflicting_timestamps_no_rows_scope_summary" "Verify Gates Selected Total Duration Conflicting Timestamps No Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	success: false,
	dryRun: true,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scope_summary" "Verify Gates Selected Run-State Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_no_evidence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-no-evidence-scope-contract',
	selectedGateIds: ['lint'],
	success: false,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_no_evidence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_no_evidence_scope_summary" "Verify Gates Selected Run-State No-Evidence Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_nonselected_evidence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-nonselected-evidence-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { build: 'pass' },
	success: false,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_nonselected_evidence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_nonselected_evidence_scope_summary" "Verify Gates Selected Run-State Nonselected-Evidence Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_unknown_status_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-unknown-status-scope-contract',
	selectedGateIds: ['lint'],
	success: false,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'MYSTERY-STATUS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: null, startedAt: '20260215T150000Z', completedAt: '20260215T150001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_unknown_status_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_unknown_status_scope_summary" "Verify Gates Selected Run-State Unknown-Status Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_partial_status_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-partial-status-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	gateStatusById: { lint: 'pass' },
	success: false,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_partial_status_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_partial_status_scope_summary" "Verify Gates Selected Run-State Partial-Status Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_failure_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-failure-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 2, exitCode: 7, startedAt: '20260215T160000Z', completedAt: '20260215T160002Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_failure_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_failure_scope_summary" "Verify Gates Selected Run-State Failure Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-scope-contract',
	selectedGateIds: ['lint'],
	success: false,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast:build' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_scope_summary" "Verify Gates Selected Run-State Not-Run Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_selected_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-selected-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast:lint' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_selected_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_selected_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Selected Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_selected_whitespace_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-selected-whitespace-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast: lint ' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_selected_whitespace_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_selected_whitespace_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Selected Whitespace Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_selected_uppercase_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-selected-uppercase-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: ' BLOCKED-BY-FAIL-FAST: lint ' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_selected_uppercase_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_selected_uppercase_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Selected Uppercase Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_selected_spaced_colon_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-selected-spaced-colon-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast : lint' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_selected_spaced_colon_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_selected_spaced_colon_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Selected Spaced-Colon Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_empty_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-empty-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast:   ' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_empty_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_empty_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Empty Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_none_sentinel_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-none-sentinel-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast: NONE ' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_none_sentinel_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_none_sentinel_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked None Sentinel Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_selected_continue_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-selected-continue-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast:lint' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_selected_continue_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_selected_continue_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Selected Continue Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_selected_dry_reason_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-selected-dry-reason-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: true,
	continueOnFailure: false,
	exitReason: 'dry-run',
	runClassification: 'dry-run',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast:lint' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_selected_dry_reason_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_selected_dry_reason_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Selected Dry-Reason Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_selected_continued_conflict_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-selected-continued-conflict-scope-contract',
	selectedGateIds: ['lint'],
	success: false,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast:lint' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_selected_continued_conflict_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_selected_continued_conflict_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Selected Continued-Conflict Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_not_run_blocked_nonselected_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-not-run-blocked-nonselected-scope-contract',
	selectedGateIds: ['lint'],
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'NOT-RUN', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 'blocked-by-fail-fast:build' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_not_run_blocked_nonselected_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_not_run_blocked_nonselected_scope_summary" "Verify Gates Selected Run-State Not-Run Blocked Nonselected Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scalar_failure_only_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scalar-failure-only-scope-contract',
	selectedGateIds: ['lint'],
	failedGateId: 'lint',
	failedGateExitCode: 7,
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scalar_failure_only_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scalar_failure_only_scope_summary" "Verify Gates Selected Run-State Scalar Failure Only Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scalar_blocked_only_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scalar-blocked-only-scope-contract',
	selectedGateIds: ['lint'],
	blockedByGateId: 'lint',
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scalar_blocked_only_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scalar_blocked_only_scope_summary" "Verify Gates Selected Run-State Scalar Blocked Only Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scalar_blocked_whitespace_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scalar-blocked-whitespace-scope-contract',
	selectedGateIds: ['lint'],
	blockedByGateId: ' lint ',
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scalar_blocked_whitespace_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scalar_blocked_whitespace_scope_summary" "Verify Gates Selected Run-State Scalar Blocked Whitespace Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scalar_blocked_empty_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scalar-blocked-empty-scope-contract',
	selectedGateIds: ['lint'],
	blockedByGateId: '   ',
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scalar_blocked_empty_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scalar_blocked_empty_scope_summary" "Verify Gates Selected Run-State Scalar Blocked Empty Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scalar_blocked_continue_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scalar-blocked-continue-scope-contract',
	selectedGateIds: ['lint'],
	blockedByGateId: 'lint',
	success: true,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scalar_blocked_continue_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scalar_blocked_continue_scope_summary" "Verify Gates Selected Run-State Scalar Blocked Continue Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scalar_blocked_dry_run_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scalar-blocked-dry-run-scope-contract',
	selectedGateIds: ['lint'],
	blockedByGateId: 'lint',
	success: true,
	dryRun: true,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scalar_blocked_dry_run_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scalar_blocked_dry_run_scope_summary" "Verify Gates Selected Run-State Scalar Blocked Dry-Run Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scalar_blocked_dry_reason_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scalar-blocked-dry-reason-scope-contract',
	selectedGateIds: ['lint'],
	blockedByGateId: 'lint',
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'dry-run',
	runClassification: 'dry-run',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scalar_blocked_dry_reason_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scalar_blocked_dry_reason_scope_summary" "Verify Gates Selected Run-State Scalar Blocked Dry-Reason Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_scalar_blocked_continued_conflict_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-scalar-blocked-continued-conflict-scope-contract',
	selectedGateIds: ['lint'],
	blockedByGateId: 'lint',
	success: false,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_scalar_blocked_continued_conflict_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_scalar_blocked_continued_conflict_scope_summary" "Verify Gates Selected Run-State Scalar Blocked Continued-Conflict Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_nonselected_blocked_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-nonselected-blocked-scope-contract',
	selectedGateIds: ['lint'],
	blockedByGateId: 'build',
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_nonselected_blocked_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_nonselected_blocked_scope_summary" "Verify Gates Selected Run-State Nonselected Blocked Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_blocked_reason_pass_status_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-blocked-reason-pass-status-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	notRunGateIds: ['lint'],
	gateNotRunReasonById: { lint: 'blocked-by-fail-fast:lint' },
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_blocked_reason_pass_status_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_blocked_reason_pass_status_scope_summary" "Verify Gates Selected Run-State Blocked-Reason Pass-Status Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_blocked_scalar_precedence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-blocked-scalar-precedence-scope-contract',
	selectedGateIds: ['typecheck', 'lint'],
	blockedByGateId: 'lint',
	gateStatusById: { lint: 'not-run', typecheck: 'not-run' },
	notRunGateIds: ['lint', 'typecheck'],
	gateNotRunReasonById: {
		lint: 'blocked-by-fail-fast:lint',
		typecheck: 'blocked-by-fail-fast:typecheck',
	},
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_blocked_scalar_precedence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_blocked_scalar_precedence_scope_summary" "Verify Gates Selected Run-State Blocked Scalar Precedence Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_blocked_reason_not_run_list_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-blocked-reason-not-run-list-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: {},
	notRunGateIds: ['lint'],
	gateNotRunReasonById: { lint: 'blocked-by-fail-fast:lint' },
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_blocked_reason_not_run_list_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_blocked_reason_not_run_list_scope_summary" "Verify Gates Selected Run-State Blocked-Reason Not-Run-List Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-blocked-reason-unknown-status-not-run-list-scope-contract',
	selectedGateIds: ['lint'],
	notRunGateIds: ['lint'],
	gateNotRunReasonById: { lint: 'blocked-by-fail-fast:lint' },
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [
		{ id: 'build', command: 'make build', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T170000Z', completedAt: '20260215T170001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_summary" "Verify Gates Selected Run-State Blocked-Reason Unknown-Status Not-Run-List Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_blocked_reason_selected_order_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-blocked-reason-selected-order-scope-contract',
	selectedGateIds: ['typecheck', 'lint'],
	gateStatusById: { lint: 'not-run', typecheck: 'not-run' },
	notRunGateIds: [' lint ', 'typecheck'],
	gateNotRunReasonById: {
		lint: 'blocked-by-fail-fast:lint',
		typecheck: 'blocked-by-fail-fast:typecheck',
	},
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_blocked_reason_selected_order_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_blocked_reason_selected_order_scope_summary" "Verify Gates Selected Run-State Blocked-Reason Selected-Order Scope Contract Test"

node - "$expected_schema_version" "$selected_non_success_partition_fallback_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-non-success-partition-fallback-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: {},
	notRunGateIds: ['lint'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_non_success_partition_fallback_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_non_success_partition_fallback_scope_summary" "Verify Gates Selected Non-Success Partition Fallback Scope Contract Test"

node - "$expected_schema_version" "$selected_non_success_status_precedence_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-non-success-status-precedence-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	notRunGateIds: ['lint'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_non_success_status_precedence_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_non_success_status_precedence_scope_summary" "Verify Gates Selected Non-Success Status Precedence Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_empty_partition_lists_status_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-empty-partition-lists-status-map-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	gateStatusById: { lint: 'pass', typecheck: 'fail' },
	passedGateIds: [],
	failedGateIds: [],
	skippedGateIds: [],
	notRunGateIds: [],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_empty_partition_lists_status_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_empty_partition_lists_status_map_scope_summary" "Verify Gates Selected Explicit Empty Partition Lists Status-Map Scope Contract Test"

node - "$expected_schema_version" "$selected_executed_fallback_empty_status_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-executed-fallback-empty-status-map-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: {},
	passedGateIds: ['lint'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_executed_fallback_empty_status_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_executed_fallback_empty_status_map_scope_summary" "Verify Gates Selected Executed Fallback Empty Status-Map Scope Contract Test"

node - "$expected_schema_version" "$selected_executed_explicit_empty_list_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-executed-explicit-empty-list-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	executedGateIds: [],
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_executed_explicit_empty_list_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_executed_explicit_empty_list_scope_summary" "Verify Gates Selected Executed Explicit Empty List Scope Contract Test"

node - "$expected_schema_version" "$selected_executed_scalar_count_ignored_empty_list_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-executed-scalar-count-ignored-empty-list-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	gateStatusById: { lint: 'pass', typecheck: 'fail' },
	executedGateIds: [],
	executedGateCount: 5,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_executed_scalar_count_ignored_empty_list_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_executed_scalar_count_ignored_empty_list_scope_summary" "Verify Gates Selected Executed Scalar Count Ignored Empty List Scope Contract Test"

node - "$expected_schema_version" "$selected_executed_fallback_partial_status_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-executed-fallback-partial-status-map-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	gateStatusById: { lint: 'pass' },
	failedGateIds: ['typecheck'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_executed_fallback_partial_status_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_executed_fallback_partial_status_map_scope_summary" "Verify Gates Selected Executed Fallback Partial Status-Map Scope Contract Test"

node - "$expected_schema_version" "$selected_attention_retried_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-attention-retried-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass', build: 'fail' },
	retriedGateIds: ['lint', 'build'],
	gateRetryCountById: { lint: 2, build: 4 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_attention_retried_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_attention_retried_scope_summary" "Verify Gates Selected Attention Retried Scope Contract Test"

node - "$expected_schema_version" "$selected_attention_retried_without_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-attention-retried-without-map-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass', build: 'fail' },
	retriedGateIds: ['lint', 'build'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_attention_retried_without_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_attention_retried_without_map_scope_summary" "Verify Gates Selected Attention Retried Without Map Scope Contract Test"

node - "$expected_schema_version" "$explicit_retried_zero_count_retry_map_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-retried-zero-count-retry-map-contract',
	gateStatusById: { lint: 'pass', build: 'pass' },
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 0, build: 4 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_retried_zero_count_retry_map_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_retried_zero_count_retry_map_summary" "Verify Gates Explicit Retried Zero Count Retry Map Contract Test"

node - "$expected_schema_version" "$explicit_retried_subset_retry_map_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-retried-subset-retry-map-contract',
	gateStatusById: { lint: 'pass', build: 'pass' },
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 3, build: 5 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_retried_subset_retry_map_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_retried_subset_retry_map_summary" "Verify Gates Explicit Retried Subset Retry Map Contract Test"

node - "$expected_schema_version" "$explicit_retried_missing_retry_map_key_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-retried-missing-retry-map-key-contract',
	retriedGateIds: ['lint'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_retried_missing_retry_map_key_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_retried_missing_retry_map_key_summary" "Verify Gates Explicit Retried Missing Retry Map Key Contract Test"

node - "$expected_schema_version" "$explicit_empty_retried_with_retry_map_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-empty-retried-with-retry-map-contract',
	gateStatusById: { lint: 'pass', build: 'pass' },
	retriedGateIds: [],
	gateRetryCountById: { lint: 3, build: 5 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_empty_retried_with_retry_map_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_empty_retried_with_retry_map_summary" "Verify Gates Explicit Empty Retried With Retry Map Contract Test"

node - "$expected_schema_version" "$scalar_failed_gate_with_empty_failed_ids_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'scalar-failed-gate-with-empty-failed-ids-contract',
	failedGateIds: [],
	failedGateExitCodes: [],
	failedGateId: ' lint ',
	failedGateExitCode: 7,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$scalar_failed_gate_with_empty_failed_ids_step_summary" ./scripts/publish-verify-gates-summary.sh "$scalar_failed_gate_with_empty_failed_ids_summary" "Verify Gates Scalar Failed Gate With Empty Failed IDs Contract Test"

node - "$expected_schema_version" "$scalar_failed_gate_selected_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'scalar-failed-gate-selected-fallback-contract',
	failedGateId: 'lint',
	failedGateExitCode: 2,
	success: false,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'failed',
	runClassification: 'failed',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$scalar_failed_gate_selected_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$scalar_failed_gate_selected_fallback_summary" "Verify Gates Scalar Failed-Gate Selected Fallback Contract Test"

node - "$expected_schema_version" "$scalar_blocked_gate_selected_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'scalar-blocked-gate-selected-fallback-contract',
	blockedByGateId: 'lint',
	success: true,
	dryRun: false,
	continueOnFailure: false,
	exitReason: 'success',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$scalar_blocked_gate_selected_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$scalar_blocked_gate_selected_fallback_summary" "Verify Gates Scalar Blocked-Gate Selected Fallback Contract Test"

node - "$expected_schema_version" "$scalar_none_sentinel_gate_ids_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'scalar-none-sentinel-gate-ids-contract',
	failedGateId: 'none',
	blockedByGateId: 'none',
	failedGateExitCode: 2,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$scalar_none_sentinel_gate_ids_step_summary" ./scripts/publish-verify-gates-summary.sh "$scalar_none_sentinel_gate_ids_summary" "Verify Gates Scalar None Sentinel Gate IDs Contract Test"

node - "$expected_schema_version" "$scalar_none_sentinel_gate_ids_case_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'scalar-none-sentinel-gate-ids-case-scope-contract',
	selectedGateIds: ['lint'],
	failedGateId: ' NONE ',
	blockedByGateId: ' NoNe ',
	failedGateExitCode: 9,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$scalar_none_sentinel_gate_ids_case_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$scalar_none_sentinel_gate_ids_case_scope_summary" "Verify Gates Scalar None Sentinel Gate IDs Case Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_attention_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-attention-scope-contract',
	selectedGateIds: ['lint'],
	nonSuccessGateIds: [' lint ', 'build'],
	attentionGateIds: ['build', ' lint '],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_attention_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_attention_scope_summary" "Verify Gates Selected Explicit Attention Scope Contract Test"

node - "$expected_schema_version" "$selected_partition_list_overlap_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-partition-list-overlap-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	passedGateIds: ['lint', 'typecheck'],
	failedGateIds: ['lint', 'build'],
	skippedGateIds: ['typecheck'],
	notRunGateIds: ['lint', 'typecheck'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_partition_list_overlap_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_partition_list_overlap_scope_summary" "Verify Gates Selected Partition List Overlap Scope Contract Test"

node - "$expected_schema_version" "$selected_partition_list_malformed_counts_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-partition-list-malformed-counts-scope-contract',
	selectedGateIds: [' lint ', ' typecheck ', 'lint', '', 1],
	gateCount: 99,
	passedGateCount: 77,
	failedGateCount: 66,
	skippedGateCount: 55,
	notRunGateCount: 44,
	executedGateCount: 33,
	statusCounts: { pass: 77, fail: 66, skip: 55, 'not-run': 44 },
	passedGateIds: [' lint ', ' typecheck ', 'lint', '', 7, 'build'],
	failedGateIds: ['lint', ' build ', ' typecheck ', null],
	skippedGateIds: [' typecheck ', 'lint', ''],
	notRunGateIds: [' lint ', 'typecheck'],
	executedGateIds: [' typecheck ', ' lint ', 'build', 'lint', 2],
	retriedGateIds: [' lint ', ' lint ', ' build '],
	nonSuccessGateIds: [' lint ', ' build ', ' typecheck ', ''],
	attentionGateIds: [' typecheck ', ' build ', ' lint ', null],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_partition_list_malformed_counts_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_partition_list_malformed_counts_scope_summary" "Verify Gates Selected Partition List Malformed Counts Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_empty_attention_with_retries_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-empty-attention-with-retries-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 2 },
	attentionGateIds: [],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_empty_attention_with_retries_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_empty_attention_with_retries_scope_summary" "Verify Gates Selected Explicit Empty Attention With Retries Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_empty_non_success_with_retries_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-empty-non-success-with-retries-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 2 },
	nonSuccessGateIds: [],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_empty_non_success_with_retries_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_empty_non_success_with_retries_scope_summary" "Verify Gates Selected Explicit Empty Non-Success With Retries Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_empty_retried_with_retry_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-empty-retried-with-retry-map-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	retriedGateIds: [],
	gateRetryCountById: { lint: 4 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_empty_retried_with_retry_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_empty_retried_with_retry_map_scope_summary" "Verify Gates Selected Explicit Empty Retried With Retry Map Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_retried_subset_retry_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-retried-subset-retry-map-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	gateStatusById: { lint: 'pass', typecheck: 'pass' },
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 3, typecheck: 5 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_retried_subset_retry_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_retried_subset_retry_map_scope_summary" "Verify Gates Selected Explicit Retried Subset Retry Map Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_retried_zero_count_retry_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-retried-zero-count-retry-map-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	gateStatusById: { lint: 'pass', typecheck: 'pass' },
	retriedGateIds: ['lint'],
	gateRetryCountById: { lint: 0, typecheck: 5 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_retried_zero_count_retry_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_retried_zero_count_retry_map_scope_summary" "Verify Gates Selected Explicit Retried Zero Count Retry Map Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_retried_missing_retry_map_key_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-retried-missing-retry-map-key-scope-contract',
	selectedGateIds: ['lint'],
	retriedGateIds: ['lint'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_retried_missing_retry_map_key_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_retried_missing_retry_map_key_scope_summary" "Verify Gates Selected Explicit Retried Missing Retry Map Key Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-retried-missing-retry-map-key-with-map-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	gateRetryCountById: { typecheck: 7 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_retried_missing_retry_map_key_with_map_scope_summary" "Verify Gates Selected Explicit Retried Missing Retry Map Key With Map Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_retried_subset_over_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-retried-subset-over-rows-scope-contract',
	selectedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	gates: [
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 3, retryCount: 2, retryBackoffSeconds: 3, durationSeconds: 4, exitCode: 0, startedAt: null, completedAt: null, notRunReason: null },
		{ id: 'typecheck', command: 'make typecheck', status: 'pass', attempts: 6, retryCount: 5, retryBackoffSeconds: 31, durationSeconds: 7, exitCode: 0, startedAt: null, completedAt: null, notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_retried_subset_over_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_retried_subset_over_rows_scope_summary" "Verify Gates Selected Explicit Retried Subset Over Rows Scope Contract Test"

node - "$expected_schema_version" "$selected_explicit_retried_nonselected_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-explicit-retried-nonselected-scope-contract',
	selectedGateIds: ['lint'],
	gateStatusById: { lint: 'pass', build: 'pass' },
	retriedGateIds: ['build'],
	gateRetryCountById: { lint: 2, build: 5 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_explicit_retried_nonselected_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_explicit_retried_nonselected_scope_summary" "Verify Gates Selected Explicit Retried Nonselected Scope Contract Test"

node - "$expected_schema_version" "$selected_run_state_unmatched_rows_scope_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'selected-run-state-unmatched-rows-scope-contract',
	selectedGateIds: ['missing-only'],
	success: false,
	dryRun: false,
	continueOnFailure: true,
	exitReason: 'completed-with-failures',
	runClassification: 'failed-continued',
	gates: [
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T130000Z', completedAt: '20260215T130001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$selected_run_state_unmatched_rows_scope_step_summary" ./scripts/publish-verify-gates-summary.sh "$selected_run_state_unmatched_rows_scope_summary" "Verify Gates Selected Run-State Unmatched Rows Scope Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_explicit_precedence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-explicit-precedence-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retriedGateCount: 9,
	totalRetryCount: 13,
	totalRetryBackoffSeconds: 21,
	executedDurationSeconds: 30,
	averageExecutedDurationSeconds: 15,
	retryRatePercent: 77,
	retryBackoffSharePercent: 70,
	passRatePercent: 88,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_explicit_precedence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_explicit_precedence_summary" "Verify Gates Unscoped Aggregate Metrics Explicit Precedence Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_explicit_no_evidence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-explicit-no-evidence-contract',
	retriedGateCount: 5,
	totalRetryCount: 7,
	totalRetryBackoffSeconds: 11,
	executedDurationSeconds: 13,
	averageExecutedDurationSeconds: 13,
	retryRatePercent: 90,
	retryBackoffSharePercent: 84,
	passRatePercent: 10,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_explicit_no_evidence_summary" "Verify Gates Unscoped Aggregate Metrics Explicit No Evidence Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_explicit_no_evidence_string_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-explicit-no-evidence-string-contract',
	retriedGateCount: '5',
	totalRetryCount: '7',
	totalRetryBackoffSeconds: '11',
	executedDurationSeconds: '13',
	averageExecutedDurationSeconds: '13',
	retryRatePercent: '90',
	retryBackoffSharePercent: '84',
	passRatePercent: '10',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_explicit_no_evidence_string_summary" "Verify Gates Unscoped Aggregate Metrics Explicit No Evidence String Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-explicit-no-evidence-string-whitespace-contract',
	retriedGateCount: ' 5 ',
	totalRetryCount: ' 7 ',
	totalRetryBackoffSeconds: ' 11 ',
	executedDurationSeconds: ' 13 ',
	averageExecutedDurationSeconds: ' 13 ',
	retryRatePercent: ' 90 ',
	retryBackoffSharePercent: ' 84 ',
	passRatePercent: ' 10 ',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_summary" "Verify Gates Unscoped Aggregate Metrics Explicit No Evidence String Whitespace Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-explicit-no-evidence-string-plus-contract',
	retriedGateCount: '+5',
	totalRetryCount: '+7',
	totalRetryBackoffSeconds: '+11',
	executedDurationSeconds: '+13',
	averageExecutedDurationSeconds: '+13',
	retryRatePercent: '+90',
	retryBackoffSharePercent: '+84',
	passRatePercent: '+10',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_summary" "Verify Gates Unscoped Aggregate Metrics Explicit No Evidence String Plus Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-no-evidence-mixed-invalid-contract',
	retriedGateCount: '7.5',
	totalRetryCount: '7e1',
	totalRetryBackoffSeconds: 11.5,
	executedDurationSeconds: '13.5',
	averageExecutedDurationSeconds: '13e1',
	retryRatePercent: 90.5,
	retryBackoffSharePercent: '84e1',
	passRatePercent: -10,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_summary" "Verify Gates Unscoped Aggregate Metrics No Evidence Mixed Invalid Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_decimal_string_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-decimal-string-fallback-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retriedGateCount: '9.5',
	totalRetryCount: '13.5',
	totalRetryBackoffSeconds: '21.5',
	executedDurationSeconds: '30.5',
	averageExecutedDurationSeconds: '15.5',
	retryRatePercent: '77.5',
	retryBackoffSharePercent: '70.5',
	passRatePercent: '88.5',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_decimal_string_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_decimal_string_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Decimal String Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_float_scalar_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-float-scalar-fallback-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retriedGateCount: 9.5,
	totalRetryCount: 13.5,
	totalRetryBackoffSeconds: 21.5,
	executedDurationSeconds: 30.5,
	averageExecutedDurationSeconds: 15.5,
	retryRatePercent: 77.5,
	retryBackoffSharePercent: 70.5,
	passRatePercent: 88.5,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_float_scalar_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_float_scalar_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Float Scalar Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_scientific_string_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-scientific-string-fallback-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retriedGateCount: '9e1',
	totalRetryCount: '13e1',
	totalRetryBackoffSeconds: '21e1',
	executedDurationSeconds: '30e1',
	averageExecutedDurationSeconds: '15e1',
	retryRatePercent: '77e1',
	retryBackoffSharePercent: '70e1',
	passRatePercent: '88e1',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_scientific_string_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_scientific_string_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Scientific String Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_string_scalar_precedence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-string-scalar-precedence-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retriedGateCount: ' 9 ',
	totalRetryCount: ' 13 ',
	totalRetryBackoffSeconds: ' 21 ',
	executedDurationSeconds: ' 30 ',
	averageExecutedDurationSeconds: ' 15 ',
	retryRatePercent: ' 77 ',
	retryBackoffSharePercent: ' 70 ',
	passRatePercent: ' 88 ',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_string_scalar_precedence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_string_scalar_precedence_summary" "Verify Gates Unscoped Aggregate Metrics String Scalar Precedence Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_partial_scalar_precedence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-partial-scalar-precedence-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retriedGateCount: 'bad',
	totalRetryCount: 9,
	totalRetryBackoffSeconds: 'bad',
	executedDurationSeconds: 30,
	averageExecutedDurationSeconds: 'bad',
	retryRatePercent: 'bad',
	retryBackoffSharePercent: 'bad',
	passRatePercent: 88,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_partial_scalar_precedence_summary" "Verify Gates Unscoped Aggregate Metrics Partial Scalar Precedence Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_negative_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-negative-fallback-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retriedGateCount: -9,
	totalRetryCount: -13,
	totalRetryBackoffSeconds: -21,
	executedDurationSeconds: -30,
	averageExecutedDurationSeconds: -15,
	retryRatePercent: -77,
	retryBackoffSharePercent: -70,
	passRatePercent: -88,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_negative_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_negative_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Negative Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_malformed_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-malformed-fallback-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retriedGateCount: 'bad',
	totalRetryCount: 'bad',
	totalRetryBackoffSeconds: 'bad',
	executedDurationSeconds: 'bad',
	averageExecutedDurationSeconds: 'bad',
	retryRatePercent: 'bad',
	retryBackoffSharePercent: 'bad',
	passRatePercent: 'bad',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_malformed_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_malformed_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Malformed Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-malformed-no-evidence-fallback-contract',
	retriedGateCount: 'bad',
	totalRetryCount: 'bad',
	totalRetryBackoffSeconds: 'bad',
	executedDurationSeconds: 'bad',
	averageExecutedDurationSeconds: 'bad',
	retryRatePercent: 'bad',
	retryBackoffSharePercent: 'bad',
	passRatePercent: 'bad',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Malformed No Evidence Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-rate-scalar-overflow-fallback-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retryRatePercent: 150,
	retryBackoffSharePercent: 140,
	passRatePercent: 120,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Rate Scalar Overflow Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-rate-scalar-overflow-no-evidence-fallback-contract',
	retryRatePercent: '150',
	retryBackoffSharePercent: '140',
	passRatePercent: '120',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Rate Scalar Overflow No Evidence Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-rate-scalar-upper-bound-precedence-contract',
	retryRatePercent: '100',
	retryBackoffSharePercent: '100',
	passRatePercent: '100',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_summary" "Verify Gates Unscoped Aggregate Metrics Rate Scalar Upper Bound Precedence Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-precedence-contract',
	retryRatePercent: '100',
	retryBackoffSharePercent: '101',
	passRatePercent: '0',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_summary" "Verify Gates Unscoped Aggregate Metrics Rate Scalar Mixed Boundary No Evidence Precedence Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-retry-rate-scalar-count-clamp-fallback-contract',
	executedGateIds: ['lint'],
	retriedGateIds: ['lint'],
	passedGateIds: ['lint'],
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 1 },
	gateDurationSecondsById: { lint: 4 },
	retriedGateCount: 5,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Retry Rate Scalar Count Clamp Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-rate-scalar-lower-bound-precedence-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retryRatePercent: 0,
	retryBackoffSharePercent: 0,
	passRatePercent: 0,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_summary" "Verify Gates Unscoped Aggregate Metrics Rate Scalar Lower Bound Precedence Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-rate-scalar-mixed-boundary-precedence-contract',
	executedGateIds: ['lint', 'typecheck'],
	retriedGateIds: ['lint'],
	passedGateIds: ['typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateRetryCountById: { lint: 1, typecheck: 0 },
	gateDurationSecondsById: { lint: 4, typecheck: 6 },
	retryRatePercent: 100,
	retryBackoffSharePercent: 101,
	passRatePercent: 0,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_summary" "Verify Gates Unscoped Aggregate Metrics Rate Scalar Mixed Boundary Precedence Contract Test"

node - "$expected_schema_version" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-aggregate-metrics-rate-derived-clamp-fallback-contract',
	executedGateIds: ['lint'],
	retriedGateIds: ['lint'],
	passedGateCount: 5,
	gateStatusById: { lint: 'pass' },
	gateRetryCountById: { lint: 3 },
	gateDurationSecondsById: { lint: 1 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_summary" "Verify Gates Unscoped Aggregate Metrics Rate Derived Clamp Fallback Contract Test"

node - "$expected_schema_version" "$derived_lists_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-lists-contract',
	gateCount: 'bad',
	passedGateCount: 'bad',
	failedGateCount: -1,
	skippedGateCount: 'bad',
	notRunGateCount: -1,
	executedGateCount: 'bad',
	totalRetryCount: 'bad',
	totalRetryBackoffSeconds: -1,
	retriedGateCount: 'bad',
	retryRatePercent: 'bad',
	passRatePercent: 'bad',
	retryBackoffSharePercent: 'bad',
	executedDurationSeconds: 'bad',
	averageExecutedDurationSeconds: 'bad',
	totalDurationSeconds: -1,
	statusCounts: { pass: 'bad', fail: -1, skip: 'bad', 'not-run': 'bad' },
	selectedGateIds: [' lint ', 'typecheck', 'test-unit', 'build', 'typecheck', '', 42],
	passedGateIds: [' lint ', 'lint', null],
	failedGateIds: ['typecheck', 'typecheck', ' '],
	failedGateExitCodes: [2, 999],
	skippedGateIds: ['test-unit', 'test-unit'],
	notRunGateIds: ['build', false],
	executedGateIds: [' lint ', 'typecheck', 'lint'],
	retriedGateIds: [' lint ', '', 'lint', 42],
	gateDurationSecondsById: { lint: 5, typecheck: 3, 'test-unit': 0, build: 0 },
	gateAttemptCountById: { lint: 1, typecheck: 1, 'test-unit': 0, build: 0 },
	gateNotRunReasonById: { lint: null, typecheck: null, 'test-unit': null, build: 'blocked-by-fail-fast:typecheck' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_lists_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_lists_summary" "Verify Gates Derived List Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_partition_scalar_counts_precedence_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-scalar-counts-precedence-contract',
	passedGateCount: 5,
	failedGateCount: 4,
	skippedGateCount: 3,
	notRunGateCount: 2,
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_scalar_counts_precedence_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_scalar_counts_precedence_summary" "Verify Gates Unscoped Partition Scalar Counts Precedence Contract Test"

node - "$expected_schema_version" "$unscoped_partition_scalar_vs_status_counts_conflict_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-scalar-vs-status-counts-conflict-contract',
	passedGateCount: 9,
	failedGateCount: 8,
	skippedGateCount: 7,
	notRunGateCount: 6,
	statusCounts: { pass: 1, fail: 2, skip: 3, 'not-run': 4 },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_scalar_vs_status_counts_conflict_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_scalar_vs_status_counts_conflict_summary" "Verify Gates Unscoped Partition Scalar Vs Status Counts Conflict Contract Test"

node - "$expected_schema_version" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-scalar-zero-raw-status-counts-conflict-contract',
	passedGateCount: 9,
	failedGateCount: 8,
	skippedGateCount: 7,
	notRunGateCount: 6,
	statusCounts: { pass: 0, fail: '0', skip: 0, 'not-run': 0 },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_scalar_zero_raw_status_counts_conflict_summary" "Verify Gates Unscoped Partition Scalar Zero Raw Status Counts Conflict Contract Test"

node - "$expected_schema_version" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-scalar-partial-zero-raw-status-counts-mix-contract',
	passedGateCount: 5,
	failedGateCount: 'bad',
	skippedGateCount: 4,
	notRunGateCount: -1,
	statusCounts: { pass: ' 0 ', fail: null, skip: 0, 'not-run': 'bad' },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	notRunGateIds: ['build'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_summary" "Verify Gates Unscoped Partition Scalar Partial Zero Raw Status Counts Mix Contract Test"

node - "$expected_schema_version" "$unscoped_partition_scalar_partial_mix_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-scalar-partial-mix-contract',
	passedGateCount: 4,
	failedGateCount: 'bad',
	skippedGateCount: 2,
	notRunGateCount: -1,
	statusCounts: { pass: 'bad', fail: 3, skip: null, 'not-run': 1 },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_scalar_partial_mix_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_scalar_partial_mix_summary" "Verify Gates Unscoped Partition Scalar Partial Mix Contract Test"

node - "$expected_schema_version" "$unscoped_partition_scalar_raw_list_hybrid_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-scalar-raw-list-hybrid-contract',
	passedGateCount: 4,
	failedGateCount: 'bad',
	skippedGateCount: 'bad',
	notRunGateCount: -1,
	statusCounts: { pass: null, fail: 3, skip: 'x', 'not-run': null },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck', 'test-unit'],
	skippedGateIds: ['build'],
	notRunGateIds: ['deploy', 'package'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_scalar_raw_list_hybrid_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_scalar_raw_list_hybrid_summary" "Verify Gates Unscoped Partition Scalar Raw List Hybrid Contract Test"

node - "$expected_schema_version" "$unscoped_partition_scalar_raw_list_status_map_hybrid_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-scalar-raw-list-status-map-hybrid-contract',
	passedGateCount: 4,
	failedGateCount: 'bad',
	skippedGateCount: 'bad',
	notRunGateCount: -1,
	statusCounts: { pass: null, fail: 3, skip: 'x', 'not-run': null },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck', 'test-unit'],
	skippedGateIds: ['build'],
	gateStatusById: { lint: 'pass', typecheck: 'fail', 'test-unit': 'fail', build: 'skip', deploy: 'not-run', package: 'not-run' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_scalar_raw_list_status_map_hybrid_summary" "Verify Gates Unscoped Partition Scalar Raw List Status Map Hybrid Contract Test"

node - "$expected_schema_version" "$unscoped_partition_scalar_invalid_fallback_status_counts_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-scalar-invalid-fallback-status-counts-contract',
	passedGateCount: 'bad',
	failedGateCount: -1,
	skippedGateCount: '1.0',
	notRunGateCount: '+2',
	statusCounts: { pass: 3, fail: 2, skip: 1, 'not-run': 0 },
	passedGateIds: ['lint', 'typecheck', 'build'],
	failedGateIds: ['test-unit', 'e2e'],
	skippedGateIds: ['docs'],
	notRunGateIds: [],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_scalar_invalid_fallback_status_counts_summary" "Verify Gates Unscoped Partition Scalar Invalid Fallback Status Counts Contract Test"

node - "$expected_schema_version" "$unscoped_status_counts_partial_status_map_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-status-counts-partial-status-map-fallback-contract',
	statusCounts: { pass: null, fail: 3, skip: 'bad', 'not-run': null },
	gateStatusById: { lint: 'pass', typecheck: 'fail', docs: 'not-run' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_status_counts_partial_status_map_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_status_counts_partial_status_map_fallback_summary" "Verify Gates Unscoped Status Counts Partial Status-Map Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_status_counts_zero_authoritative_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-status-counts-zero-authoritative-contract',
	statusCounts: { pass: 0, fail: '0', skip: 0, 'not-run': 0 },
	gateStatusById: { lint: 'pass', typecheck: 'fail', docs: 'not-run' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_status_counts_zero_authoritative_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_status_counts_zero_authoritative_summary" "Verify Gates Unscoped Status Counts Zero Authoritative Contract Test"

node - "$expected_schema_version" "$unscoped_status_counts_partial_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-status-counts-partial-fallback-contract',
	statusCounts: { pass: '2', fail: 'x', skip: 1, 'not-run': null },
	passedGateIds: ['lint'],
	failedGateIds: ['typecheck'],
	notRunGateIds: ['build'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_status_counts_partial_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_status_counts_partial_fallback_summary" "Verify Gates Unscoped Status Counts Partial Fallback Contract Test"

node - "$expected_schema_version" "$unscoped_partition_list_overlap_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-list-overlap-contract',
	passedGateIds: ['lint', 'typecheck'],
	failedGateIds: ['lint'],
	skippedGateIds: ['typecheck', 'build'],
	notRunGateIds: ['build', 'lint'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_list_overlap_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_list_overlap_summary" "Verify Gates Unscoped Partition List Overlap Contract Test"

node - "$expected_schema_version" "$unscoped_partition_list_malformed_counts_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-partition-list-malformed-counts-contract',
	gateCount: '+9',
	passedGateCount: 'x',
	failedGateCount: '-1',
	skippedGateCount: 1.2,
	notRunGateCount: '4e0',
	executedGateCount: '+7',
	statusCounts: { pass: '+1', fail: '-2', skip: '1.0', 'not-run': 'x' },
	passedGateIds: [' lint ', 'typecheck', '', 'lint', 4],
	failedGateIds: [' lint ', ' build ', null],
	skippedGateIds: ['build', ' typecheck ', 'build'],
	notRunGateIds: ['deploy', ' typecheck ', '', 'lint'],
	retriedGateIds: [' typecheck ', 'build', 'build', 5],
	nonSuccessGateIds: [' lint ', ' deploy ', ' build ', ''],
	attentionGateIds: [' typecheck ', ' deploy ', ' build ', ' build '],
	gateRetryCountById: { ' typecheck ': '2', build: '1', lint: 'x', deploy: -1 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_partition_list_malformed_counts_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_partition_list_malformed_counts_summary" "Verify Gates Unscoped Partition List Malformed Counts Contract Test"

node - "$expected_schema_version" "$unscoped_explicit_empty_partition_lists_status_map_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-explicit-empty-partition-lists-status-map-contract',
	gateStatusById: { lint: 'pass', typecheck: 'fail' },
	passedGateIds: [],
	failedGateIds: [],
	skippedGateIds: [],
	notRunGateIds: [],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_explicit_empty_partition_lists_status_map_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_explicit_empty_partition_lists_status_map_summary" "Verify Gates Unscoped Explicit Empty Partition Lists Status-Map Contract Test"

node - "$expected_schema_version" "$unscoped_executed_fallback_empty_status_map_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-executed-fallback-empty-status-map-contract',
	gateStatusById: {},
	passedGateIds: ['typecheck'],
	failedGateIds: ['lint'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_executed_fallback_empty_status_map_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_executed_fallback_empty_status_map_summary" "Verify Gates Unscoped Executed Fallback Empty Status-Map Contract Test"

node - "$expected_schema_version" "$unscoped_executed_explicit_empty_list_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-executed-explicit-empty-list-contract',
	passedGateIds: ['typecheck'],
	failedGateIds: ['lint'],
	executedGateIds: [],
	retriedGateIds: ['typecheck'],
	gateRetryCountById: { typecheck: 2, lint: 0 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_executed_explicit_empty_list_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_executed_explicit_empty_list_summary" "Verify Gates Unscoped Executed Explicit Empty List Contract Test"

node - "$expected_schema_version" "$unscoped_executed_scalar_count_overrides_empty_list_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-executed-scalar-count-overrides-empty-list-contract',
	gateStatusById: { lint: 'pass', build: 'fail' },
	executedGateIds: [],
	executedGateCount: 5,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_executed_scalar_count_overrides_empty_list_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_executed_scalar_count_overrides_empty_list_summary" "Verify Gates Unscoped Executed Scalar Count Overrides Empty List Contract Test"

node - "$expected_schema_version" "$unscoped_executed_fallback_partial_status_map_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'unscoped-executed-fallback-partial-status-map-contract',
	gateStatusById: { typecheck: 'pass' },
	failedGateIds: ['lint'],
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$unscoped_executed_fallback_partial_status_map_step_summary" ./scripts/publish-verify-gates-summary.sh "$unscoped_executed_fallback_partial_status_map_summary" "Verify Gates Unscoped Executed Fallback Partial Status-Map Contract Test"

node - "$expected_schema_version" "$derived_status_map_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-status-map-contract',
	gateStatusById: { ' lint ': ' PASS ', typecheck: 'FAIL', build: ' Not-Run ', ignored: 'unknown', '': 'pass' },
	gateExitCodeById: { ' lint ': '-7', typecheck: '5', build: null, bad: 'x' },
	failedGateId: 'typecheck',
	failedGateExitCode: '-2',
	gateRetryCountById: { ' lint ': '2', typecheck: '0', build: 0, bad: -1 },
	gateDurationSecondsById: { ' lint ': '1', typecheck: '2', build: 0, bad: -1 },
	gateAttemptCountById: { ' lint ': '1', typecheck: 1, build: 0, bad: 'oops' },
	gateNotRunReasonById: { ' lint ': 123, typecheck: null, build: 'blocked-by-fail-fast:typecheck', bad: 5 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_status_map_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_status_map_summary" "Verify Gates Derived Status-Map Contract Test"

node - "$expected_schema_version" "$status_map_duplicate_keys_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'status-map-duplicate-keys-contract',
	gateStatusById: { ' lint ': ' PASS ', lint: 'fail' },
	gateExitCodeById: { ' lint ': '1', lint: '7' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$status_map_duplicate_keys_step_summary" ./scripts/publish-verify-gates-summary.sh "$status_map_duplicate_keys_summary" "Verify Gates Status-Map Duplicate Keys Contract Test"

node - "$expected_schema_version" "$duplicate_normalized_map_keys_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'duplicate-normalized-map-keys-contract',
	gateStatusById: { ' lint ': 'pass' },
	gateRetryCountById: { ' lint ': '1', lint: '4' },
	gateDurationSecondsById: { ' lint ': '2', lint: '6' },
	gateAttemptCountById: { ' lint ': '1', lint: '3' },
	gateNotRunReasonById: { ' lint ': ' first ', lint: ' second ' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$duplicate_normalized_map_keys_step_summary" ./scripts/publish-verify-gates-summary.sh "$duplicate_normalized_map_keys_summary" "Verify Gates Duplicate Normalized Map Keys Contract Test"

node - "$expected_schema_version" "$derived_dry_run_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-dry-run-contract',
	dryRun: true,
	selectedGateIds: ['lint'],
	skippedGateIds: ['lint'],
	gateStatusById: { lint: 'skip' },
	gateExitCodeById: { lint: null },
	gateRetryCountById: { lint: 0 },
	gateDurationSecondsById: { lint: 0 },
	gateAttemptCountById: { lint: 0 },
	gateNotRunReasonById: { lint: null },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_dry_run_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_dry_run_summary" "Verify Gates Derived Dry-Run Contract Test"

node - "$expected_schema_version" "$derived_continued_failure_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-continued-failure-contract',
	selectedGateIds: ['lint', 'typecheck'],
	passedGateIds: ['typecheck'],
	failedGateIds: ['lint'],
	executedGateIds: ['lint', 'typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateExitCodeById: { lint: 7, typecheck: 0 },
	gateRetryCountById: { lint: 0, typecheck: 0 },
	gateDurationSecondsById: { lint: 2, typecheck: 1 },
	gateAttemptCountById: { lint: 1, typecheck: 1 },
	gateNotRunReasonById: { lint: null, typecheck: null },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_continued_failure_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_continued_failure_summary" "Verify Gates Derived Continued-Failure Contract Test"

node - "$expected_schema_version" "$explicit_reason_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-reason-contract',
	exitReason: '  COMPLETED-WITH-FAILURES  ',
	continueOnFailure: 'off',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_reason_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_reason_summary" "Verify Gates Explicit Reason Contract Test"

node - "$expected_schema_version" "$invalid_reason_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'invalid-reason-contract',
	exitReason: 'bogus-value',
	gateStatusById: { lint: 'fail', typecheck: 'not-run' },
	gateNotRunReasonById: { lint: null, typecheck: 'blocked-by-fail-fast:lint' },
	gateExitCodeById: { lint: 9, typecheck: null },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invalid_reason_step_summary" ./scripts/publish-verify-gates-summary.sh "$invalid_reason_summary" "Verify Gates Invalid Reason Contract Test"

node - "$expected_schema_version" "$explicit_run_classification_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-run-classification-contract',
	runClassification: '  SUCCESS-NO-RETRIES  ',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_run_classification_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_run_classification_summary" "Verify Gates Explicit Run Classification Contract Test"

node - "$expected_schema_version" "$conflicting_reason_classification_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'conflicting-reason-classification-contract',
	exitReason: ' fail-fast ',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$conflicting_reason_classification_step_summary" ./scripts/publish-verify-gates-summary.sh "$conflicting_reason_classification_summary" "Verify Gates Conflicting Reason/Classification Contract Test"

node - "$expected_schema_version" "$conflicting_run_state_flags_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'conflicting-run-state-flags-contract',
	exitReason: 'fail-fast',
	runClassification: 'success-with-retries',
	success: true,
	dryRun: true,
	continueOnFailure: true,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$conflicting_run_state_flags_step_summary" ./scripts/publish-verify-gates-summary.sh "$conflicting_run_state_flags_summary" "Verify Gates Conflicting Run-State Flags Contract Test"

node - "$expected_schema_version" "$conflicting_classification_flags_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'conflicting-classification-flags-contract',
	runClassification: 'failed-continued',
	success: 'yes',
	dryRun: 'ON',
	continueOnFailure: '0',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$conflicting_classification_flags_step_summary" ./scripts/publish-verify-gates-summary.sh "$conflicting_classification_flags_summary" "Verify Gates Conflicting Classification Flags Contract Test"

node - "$expected_schema_version" "$invalid_reason_with_classification_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'invalid-reason-with-classification-contract',
	exitReason: 'definitely-not-valid',
	runClassification: 'FAILED-FAIL-FAST',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invalid_reason_with_classification_step_summary" ./scripts/publish-verify-gates-summary.sh "$invalid_reason_with_classification_summary" "Verify Gates Invalid Reason With Classification Contract Test"

node - "$expected_schema_version" "$invalid_classification_with_reason_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'invalid-classification-with-reason-contract',
	exitReason: 'completed-with-failures',
	runClassification: 'totally-invalid',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invalid_classification_with_reason_step_summary" ./scripts/publish-verify-gates-summary.sh "$invalid_classification_with_reason_summary" "Verify Gates Invalid Classification With Reason Contract Test"

node - "$expected_schema_version" "$dry_run_reason_conflicts_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'dry-run-reason-conflicts-contract',
	exitReason: 'dry-run',
	runClassification: 'failed-fail-fast',
	success: false,
	dryRun: false,
	continueOnFailure: true,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$dry_run_reason_conflicts_step_summary" ./scripts/publish-verify-gates-summary.sh "$dry_run_reason_conflicts_summary" "Verify Gates Dry-Run Reason Conflicts Contract Test"

node - "$expected_schema_version" "$success_reason_conflicts_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'success-reason-conflicts-contract',
	exitReason: 'success',
	runClassification: 'failed-continued',
	success: false,
	dryRun: true,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$success_reason_conflicts_step_summary" ./scripts/publish-verify-gates-summary.sh "$success_reason_conflicts_summary" "Verify Gates Success Reason Conflicts Contract Test"

node - "$expected_schema_version" "$success_reason_explicit_continue_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'success-reason-explicit-continue-contract',
	exitReason: 'success',
	runClassification: 'failed-continued',
	continueOnFailure: 'on',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$success_reason_explicit_continue_step_summary" ./scripts/publish-verify-gates-summary.sh "$success_reason_explicit_continue_summary" "Verify Gates Success Reason Explicit Continue Contract Test"

node - "$expected_schema_version" "$success_classification_explicit_continue_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'success-classification-explicit-continue-contract',
	runClassification: '  SUCCESS-WITH-RETRIES  ',
	success: false,
	dryRun: true,
	continueOnFailure: 'yes',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$success_classification_explicit_continue_step_summary" ./scripts/publish-verify-gates-summary.sh "$success_classification_explicit_continue_summary" "Verify Gates Success Classification Explicit Continue Contract Test"

node - "$expected_schema_version" "$numeric_boolean_flags_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'numeric-boolean-flags-contract',
	success: 1,
	dryRun: 0,
	continueOnFailure: 0,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$numeric_boolean_flags_step_summary" ./scripts/publish-verify-gates-summary.sh "$numeric_boolean_flags_summary" "Verify Gates Numeric Boolean Flags Contract Test"

node - "$expected_schema_version" "$invalid_numeric_boolean_flags_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'invalid-numeric-boolean-flags-contract',
	exitReason: 'fail-fast',
	success: 2,
	dryRun: 2,
	continueOnFailure: 2,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invalid_numeric_boolean_flags_step_summary" ./scripts/publish-verify-gates-summary.sh "$invalid_numeric_boolean_flags_summary" "Verify Gates Invalid Numeric Boolean Flags Contract Test"

node - "$expected_schema_version" "$dry_summary" "$dry_repeat_summary" "$continue_true_summary" "$continue_false_summary" "$continue_flag_summary" "$dedupe_summary" "$from_summary" "$full_dry_summary" "$default_mode_dry_summary" "$mode_precedence_full_summary" "$mode_precedence_quick_summary" "$env_retries_summary" "$cli_retries_override_summary" "$continue_fail_summary" "$continue_multi_fail_summary" "$fail_fast_summary" "$retry_summary" "$continue_fail_step_summary" "$continue_multi_fail_step_summary" "$fail_fast_step_summary" "$retry_step_summary" "$continue_flag_step_summary" "$dry_fallback_step_summary" "$fail_fast_fallback_step_summary" "$fallback_step_summary" <<'NODE'
const fs = require('node:fs');
const [expectedSchemaVersionRaw, dryPath, dryRepeatPath, continueTruePath, continueFalsePath, continueFlagPath, dedupePath, fromPath, fullDryPath, defaultModeDryPath, modePrecedenceFullPath, modePrecedenceQuickPath, envRetriesPath, cliRetriesOverridePath, continueFailPath, continueMultiFailPath, failFastPath, retryPath, continueFailStepPath, continueMultiFailStepPath, failFastStepPath, retryStepPath, continueFlagStepPath, dryFallbackStepPath, failFastFallbackStepPath, fallbackStepPath] = process.argv.slice(2);
const expectedSchemaVersion = Number.parseInt(expectedSchemaVersionRaw, 10);
if (!Number.isInteger(expectedSchemaVersion) || expectedSchemaVersion <= 0) {
	throw new Error(`Invalid expected schema version: ${expectedSchemaVersionRaw}`);
}
const dry = JSON.parse(fs.readFileSync(dryPath, 'utf8'));
const dryRepeat = JSON.parse(fs.readFileSync(dryRepeatPath, 'utf8'));
const continueTrue = JSON.parse(fs.readFileSync(continueTruePath, 'utf8'));
const continueFalse = JSON.parse(fs.readFileSync(continueFalsePath, 'utf8'));
const continueFlag = JSON.parse(fs.readFileSync(continueFlagPath, 'utf8'));
const dedupe = JSON.parse(fs.readFileSync(dedupePath, 'utf8'));
const from = JSON.parse(fs.readFileSync(fromPath, 'utf8'));
const fullDry = JSON.parse(fs.readFileSync(fullDryPath, 'utf8'));
const defaultModeDry = JSON.parse(fs.readFileSync(defaultModeDryPath, 'utf8'));
const modePrecedenceFull = JSON.parse(fs.readFileSync(modePrecedenceFullPath, 'utf8'));
const modePrecedenceQuick = JSON.parse(fs.readFileSync(modePrecedenceQuickPath, 'utf8'));
const envRetries = JSON.parse(fs.readFileSync(envRetriesPath, 'utf8'));
const cliRetriesOverride = JSON.parse(fs.readFileSync(cliRetriesOverridePath, 'utf8'));
const continueFail = JSON.parse(fs.readFileSync(continueFailPath, 'utf8'));
const continueMultiFail = JSON.parse(fs.readFileSync(continueMultiFailPath, 'utf8'));
const failFast = JSON.parse(fs.readFileSync(failFastPath, 'utf8'));
const retry = JSON.parse(fs.readFileSync(retryPath, 'utf8'));
const continueFailStep = fs.readFileSync(continueFailStepPath, 'utf8');
const continueMultiFailStep = fs.readFileSync(continueMultiFailStepPath, 'utf8');
const failFastStep = fs.readFileSync(failFastStepPath, 'utf8');
const retryStep = fs.readFileSync(retryStepPath, 'utf8');
const continueFlagStep = fs.readFileSync(continueFlagStepPath, 'utf8');
const dryFallbackStep = fs.readFileSync(dryFallbackStepPath, 'utf8');
const failFastFallbackStep = fs.readFileSync(failFastFallbackStepPath, 'utf8');
const fallbackStep = fs.readFileSync(fallbackStepPath, 'utf8');
const assertGateExitCodeSemantics = (label, summary) => {
	if (!Array.isArray(summary.gates)) {
		throw new Error(`${label} summary gates should be an array.`);
	}
	if (!summary.gateExitCodeById || typeof summary.gateExitCodeById !== 'object' || Array.isArray(summary.gateExitCodeById)) {
		throw new Error(`${label} summary gateExitCodeById should be an object.`);
	}
	for (const gate of summary.gates) {
		const gateId = gate.id;
		if (typeof gateId !== 'string' || gateId.length === 0) {
			throw new Error(`${label} summary gate missing id.`);
		}
		const status = gate.status;
		const exitCode = gate.exitCode;
		const mappedExitCode = summary.gateExitCodeById[gateId];
		const isExecuted = status === 'pass' || status === 'fail';
		if (isExecuted) {
			if (!Number.isInteger(exitCode)) {
				throw new Error(`${label} executed gate ${gateId} should have an integer exit code.`);
			}
			if (!Number.isInteger(mappedExitCode) || mappedExitCode !== exitCode) {
				throw new Error(`${label} gateExitCodeById mismatch for executed gate ${gateId}.`);
			}
			continue;
		}
		if (exitCode !== null) {
			throw new Error(`${label} non-executed gate ${gateId} should have null exit code in gate rows.`);
		}
		if (mappedExitCode !== null) {
			throw new Error(`${label} non-executed gate ${gateId} should have null exit code in gateExitCodeById.`);
		}
	}
};

if (dry.schemaVersion !== expectedSchemaVersion || continueFail.schemaVersion !== expectedSchemaVersion || continueMultiFail.schemaVersion !== expectedSchemaVersion || failFast.schemaVersion !== expectedSchemaVersion || retry.schemaVersion !== expectedSchemaVersion) {
	throw new Error(`Expected schema version ${expectedSchemaVersion} for all runs.`);
}
if (dryRepeat.schemaVersion !== expectedSchemaVersion || continueTrue.schemaVersion !== expectedSchemaVersion || continueFalse.schemaVersion !== expectedSchemaVersion || continueFlag.schemaVersion !== expectedSchemaVersion || dedupe.schemaVersion !== expectedSchemaVersion || from.schemaVersion !== expectedSchemaVersion || fullDry.schemaVersion !== expectedSchemaVersion || defaultModeDry.schemaVersion !== expectedSchemaVersion || modePrecedenceFull.schemaVersion !== expectedSchemaVersion || modePrecedenceQuick.schemaVersion !== expectedSchemaVersion || envRetries.schemaVersion !== expectedSchemaVersion || cliRetriesOverride.schemaVersion !== expectedSchemaVersion) {
	throw new Error(`Expected schema version ${expectedSchemaVersion} for dedupe/from runs.`);
}
for (const [label, summary] of [['dry', dry], ['dry-repeat', dryRepeat], ['continue-true', continueTrue], ['continue-false', continueFalse], ['continue-flag', continueFlag], ['dedupe', dedupe], ['from', from], ['full-dry', fullDry], ['default-mode-dry', defaultModeDry], ['mode-precedence-full', modePrecedenceFull], ['mode-precedence-quick', modePrecedenceQuick], ['env-retries', envRetries], ['cli-retries-override', cliRetriesOverride], ['continue-fail', continueFail], ['continue-multi-fail', continueMultiFail], ['fail-fast', failFast], ['retry', retry]]) {
	const statusCounts = summary.statusCounts ?? {};
	const passCount = summary.passedGateCount ?? 0;
	const failCount = summary.failedGateCount ?? 0;
	const skipCount = summary.skippedGateCount ?? 0;
	const notRunCount = summary.notRunGateCount ?? 0;
	if (statusCounts.pass !== passCount || statusCounts.fail !== failCount || statusCounts.skip !== skipCount || statusCounts['not-run'] !== notRunCount) {
		throw new Error(`${label} summary statusCounts mismatch with scalar counters.`);
	}
	if (!Array.isArray(summary.passedGateIds) || summary.passedGateIds.length !== passCount) {
		throw new Error(`${label} passedGateIds length mismatch.`);
	}
	if (!Array.isArray(summary.failedGateIds) || summary.failedGateIds.length !== failCount) {
		throw new Error(`${label} failedGateIds length mismatch.`);
	}
	if (!Array.isArray(summary.skippedGateIds) || summary.skippedGateIds.length !== skipCount) {
		throw new Error(`${label} skippedGateIds length mismatch.`);
	}
	if (!Array.isArray(summary.notRunGateIds) || summary.notRunGateIds.length !== notRunCount) {
		throw new Error(`${label} notRunGateIds length mismatch.`);
	}
	assertGateExitCodeSemantics(label, summary);
}
if (dry.exitReason !== 'dry-run' || dry.runClassification !== 'dry-run') {
	throw new Error('Dry-run exit reason/classification mismatch.');
}
if (continueTrue.exitReason !== 'dry-run' || continueTrue.runClassification !== 'dry-run' || continueFalse.exitReason !== 'dry-run' || continueFalse.runClassification !== 'dry-run' || continueFlag.exitReason !== 'dry-run' || continueFlag.runClassification !== 'dry-run') {
	throw new Error('Continue-on-failure dry-run classification mismatch.');
}
if (typeof dry.resultSignatureAlgorithm !== 'string' || dry.resultSignatureAlgorithm.length === 0) {
	throw new Error('Dry-run resultSignatureAlgorithm should be populated.');
}
if (dry.resultSignature !== dryRepeat.resultSignature) {
	throw new Error('Repeated identical dry-runs should produce identical result signatures.');
}
if (dry.resultSignature === dedupe.resultSignature) {
	throw new Error('Different gate selections should produce different result signatures.');
}
const timestampPattern = /^\d{8}T\d{6}Z$/;
for (const [label, summary] of [['dry', dry], ['dry-repeat', dryRepeat], ['dedupe', dedupe], ['from', from], ['full-dry', fullDry], ['default-mode-dry', defaultModeDry], ['mode-precedence-full', modePrecedenceFull], ['mode-precedence-quick', modePrecedenceQuick], ['env-retries', envRetries], ['cli-retries-override', cliRetriesOverride], ['continue-fail', continueFail], ['continue-multi-fail', continueMultiFail], ['fail-fast', failFast], ['retry', retry]]) {
	const expectedRunIdPrefix = label === 'full-dry' || label === 'default-mode-dry' || label === 'mode-precedence-full' ? 'full-' : 'quick-';
	if (typeof summary.runId !== 'string' || !summary.runId.startsWith(expectedRunIdPrefix)) {
		throw new Error(`${label} summary runId should start with ${expectedRunIdPrefix}.`);
	}
	if (!timestampPattern.test(String(summary.startedAt ?? '')) || !timestampPattern.test(String(summary.completedAt ?? ''))) {
		throw new Error(`${label} summary timestamps should match YYYYMMDDTHHMMSSZ.`);
	}
	if (!Number.isInteger(summary.totalDurationSeconds) || summary.totalDurationSeconds < 0) {
		throw new Error(`${label} summary totalDurationSeconds should be a non-negative integer.`);
	}
	if (!Number.isInteger(summary.gateCount) || !Array.isArray(summary.selectedGateIds) || summary.gateCount !== summary.selectedGateIds.length) {
		throw new Error(`${label} summary gateCount/selectedGateIds mismatch.`);
	}
}
if (!fullDry.runId.startsWith('full-') || fullDry.mode !== 'full') {
	throw new Error('Full dry-run should emit full-mode run metadata.');
}
if (fullDry.selectedGateIds.join(',') !== 'build' || fullDry.skippedGateIds.join(',') !== 'build') {
	throw new Error('Full dry-run gate selection/partition mismatch.');
}
if (defaultModeDry.mode !== 'full' || !defaultModeDry.runId.startsWith('full-')) {
	throw new Error('Default-mode dry-run should resolve to full mode metadata.');
}
if (defaultModeDry.selectedGateIds.join(',') !== 'build' || defaultModeDry.skippedGateIds.join(',') !== 'build') {
	throw new Error('Default-mode dry-run gate selection/partition mismatch.');
}
if (modePrecedenceFull.mode !== 'full' || !modePrecedenceFull.runId.startsWith('full-')) {
	throw new Error('Mode precedence should use final --full flag.');
}
if (modePrecedenceFull.selectedGateIds.join(',') !== 'build' || modePrecedenceFull.skippedGateIds.join(',') !== 'build') {
	throw new Error('Mode precedence full selection/partition mismatch.');
}
if (modePrecedenceQuick.mode !== 'quick' || !modePrecedenceQuick.runId.startsWith('quick-')) {
	throw new Error('Mode precedence should use final --quick flag.');
}
if (modePrecedenceQuick.selectedGateIds.join(',') !== 'test-unit' || modePrecedenceQuick.skippedGateIds.join(',') !== 'test-unit') {
	throw new Error('Mode precedence quick selection/partition mismatch.');
}
if (envRetries.retries !== 2 || envRetries.mode !== 'quick' || envRetries.selectedGateIds.join(',') !== 'lint') {
	throw new Error('Expected VSCODE_VERIFY_RETRIES to control retries in dry-run metadata.');
}
if (cliRetriesOverride.retries !== 0 || cliRetriesOverride.mode !== 'quick' || cliRetriesOverride.selectedGateIds.join(',') !== 'lint') {
	throw new Error('Expected --retries flag to override VSCODE_VERIFY_RETRIES.');
}
if (continueFail.continueOnFailure !== true || continueFail.dryRun !== false || continueFail.mode !== 'quick') {
	throw new Error('Continue-on-failure failure run metadata mismatch.');
}
if (continueFail.exitReason !== 'completed-with-failures' || continueFail.runClassification !== 'failed-continued') {
	throw new Error('Continue-on-failure failure exit reason/classification mismatch.');
}
if (continueFail.gateStatusById.lint !== 'fail' || continueFail.gateStatusById.typecheck !== 'pass') {
	throw new Error('Continue-on-failure failure gate status map mismatch.');
}
if (continueFail.gateAttemptCountById.lint !== 1 || continueFail.gateAttemptCountById.typecheck !== 1 || continueFail.gateRetryCountById.lint !== 0 || continueFail.gateRetryCountById.typecheck !== 0) {
	throw new Error('Continue-on-failure failure gate attempt/retry map mismatch.');
}
if (continueFail.gateExitCodeById.lint !== 7 || continueFail.gateExitCodeById.typecheck !== 0 || continueFail.failedGateExitCode !== 7) {
	throw new Error('Continue-on-failure failure exit-code metadata mismatch.');
}
if (continueFail.failedGateId !== 'lint' || continueFail.blockedByGateId !== null) {
	throw new Error('Continue-on-failure failure gate pointers mismatch.');
}
if (continueFail.failedGateIds.join(',') !== 'lint' || continueFail.failedGateExitCodes.join(',') !== '7') {
	throw new Error('Continue-on-failure failure partitions mismatch for failed gates.');
}
if (continueFail.executedGateIds.join(',') !== 'lint,typecheck' || continueFail.notRunGateIds.length !== 0) {
	throw new Error('Continue-on-failure failure executed/not-run partition mismatch.');
}
if (continueFail.nonSuccessGateIds.join(',') !== 'lint' || continueFail.attentionGateIds.join(',') !== 'lint') {
	throw new Error('Continue-on-failure failure non-success/attention partition mismatch.');
}
if (continueFail.retriedGateIds.length !== 0 || continueFail.retriedGateCount !== 0) {
	throw new Error('Continue-on-failure failure should not report retries.');
}
if (continueMultiFail.continueOnFailure !== true || continueMultiFail.dryRun !== false || continueMultiFail.mode !== 'quick') {
	throw new Error('Continue-on-failure multi-failure run metadata mismatch.');
}
if (continueMultiFail.exitReason !== 'completed-with-failures' || continueMultiFail.runClassification !== 'failed-continued') {
	throw new Error('Continue-on-failure multi-failure exit reason/classification mismatch.');
}
if (continueMultiFail.gateStatusById.lint !== 'fail' || continueMultiFail.gateStatusById.typecheck !== 'fail') {
	throw new Error('Continue-on-failure multi-failure gate status map mismatch.');
}
if (continueMultiFail.gateAttemptCountById.lint !== 1 || continueMultiFail.gateAttemptCountById.typecheck !== 1 || continueMultiFail.gateRetryCountById.lint !== 0 || continueMultiFail.gateRetryCountById.typecheck !== 0) {
	throw new Error('Continue-on-failure multi-failure gate attempt/retry map mismatch.');
}
if (continueMultiFail.gateExitCodeById.lint !== 7 || continueMultiFail.gateExitCodeById.typecheck !== 3 || continueMultiFail.failedGateExitCode !== 7) {
	throw new Error('Continue-on-failure multi-failure exit-code metadata mismatch.');
}
if (continueMultiFail.failedGateId !== 'lint' || continueMultiFail.blockedByGateId !== null) {
	throw new Error('Continue-on-failure multi-failure gate pointers mismatch.');
}
if (continueMultiFail.failedGateIds.join(',') !== 'lint,typecheck' || continueMultiFail.failedGateExitCodes.join(',') !== '7,3') {
	throw new Error('Continue-on-failure multi-failure partitions mismatch for failed gates.');
}
if (continueMultiFail.executedGateIds.join(',') !== 'lint,typecheck' || continueMultiFail.notRunGateIds.length !== 0) {
	throw new Error('Continue-on-failure multi-failure executed/not-run partition mismatch.');
}
if (continueMultiFail.nonSuccessGateIds.join(',') !== 'lint,typecheck' || continueMultiFail.attentionGateIds.join(',') !== 'lint,typecheck') {
	throw new Error('Continue-on-failure multi-failure non-success/attention partition mismatch.');
}
if (continueMultiFail.retriedGateIds.length !== 0 || continueMultiFail.retriedGateCount !== 0) {
	throw new Error('Continue-on-failure multi-failure should not report retries.');
}
if (!Array.isArray(failFast.executedGateIds) || failFast.executedGateCount !== failFast.executedGateIds.length) {
	throw new Error('Fail-fast executed gate count/list mismatch.');
}
if (!Array.isArray(retry.executedGateIds) || retry.executedGateCount !== retry.executedGateIds.length) {
	throw new Error('Retry-success executed gate count/list mismatch.');
}
for (const [label, summary] of [['dry', dry], ['continue-fail', continueFail], ['continue-multi-fail', continueMultiFail], ['fail-fast', failFast], ['retry', retry]]) {
	if (typeof summary.logFile !== 'string' || summary.logFile.length === 0) {
		throw new Error(`${label} summary missing logFile path.`);
	}
	if (!summary.logFile.includes('/logs/')) {
		throw new Error(`${label} logFile path should point to log directory.`);
	}
	if (!fs.existsSync(summary.logFile)) {
		throw new Error(`${label} logFile path does not exist on disk.`);
	}
}
if (continueTrue.continueOnFailure !== true) {
	throw new Error('continue-on-failure env=true normalization mismatch.');
}
if (continueFalse.continueOnFailure !== false) {
	throw new Error('continue-on-failure env=off normalization mismatch.');
}
if (continueFlag.continueOnFailure !== true) {
	throw new Error('continue-on-failure CLI flag normalization mismatch.');
}

if (dry.gateAttemptCountById.lint !== 0 || dry.gateRetryCountById.lint !== 0) {
	throw new Error('Dry-run gate attempt/retry map mismatch.');
}
if (dedupe.selectedGateIds.join(',') !== 'lint,typecheck') {
	throw new Error('Duplicate/whitespace --only normalization mismatch.');
}
if (from.selectedGateIds.join(',') !== 'typecheck,test-unit') {
	throw new Error('--from gate selection mismatch.');
}
if (from.skippedGateIds.join(',') !== 'typecheck,test-unit') {
	throw new Error('--from dry-run skipped partition mismatch.');
}

if (failFast.gateStatusById.lint !== 'fail' || failFast.gateStatusById.typecheck !== 'not-run') {
	throw new Error('Fail-fast gate status map mismatch.');
}
if (failFast.exitReason !== 'fail-fast' || failFast.runClassification !== 'failed-fail-fast') {
	throw new Error('Fail-fast exit reason/classification mismatch.');
}
if (failFast.failedGateId !== 'lint' || failFast.failedGateExitCode !== 7 || failFast.blockedByGateId !== 'lint') {
	throw new Error('Fail-fast first-failure metadata mismatch.');
}
if (failFast.nonSuccessGateIds.join(',') !== 'lint,typecheck' || failFast.attentionGateIds.join(',') !== 'lint,typecheck') {
	throw new Error('Fail-fast partition metadata mismatch.');
}
if (failFast.gateNotRunReasonById.typecheck !== 'blocked-by-fail-fast:lint') {
	throw new Error('Fail-fast not-run reason map mismatch.');
}
if (failFast.gateAttemptCountById.lint !== 1 || failFast.gateAttemptCountById.typecheck !== 0) {
	throw new Error('Fail-fast attempt map mismatch.');
}

if (retry.gateStatusById.lint !== 'pass' || retry.gateStatusById.typecheck !== 'pass') {
	throw new Error('Retry-success gate status map mismatch.');
}
if (retry.exitReason !== 'success' || retry.runClassification !== 'success-with-retries') {
	throw new Error('Retry-success exit reason/classification mismatch.');
}
if (retry.gateRetryCountById.lint !== 1 || retry.gateAttemptCountById.lint !== 2 || retry.gateAttemptCountById.typecheck !== 1) {
	throw new Error('Retry-success retry/attempt map mismatch.');
}
if (retry.attentionGateIds.join(',') !== 'lint') {
	throw new Error('Retry-success attention-gates partition mismatch.');
}
if (retry.nonSuccessGateIds.length !== 0 || retry.failedGateId !== null || retry.failedGateExitCode !== null || retry.blockedByGateId !== null) {
	throw new Error('Retry-success failure metadata should be empty.');
}

if (!/\*\*Gate not-run reason map:\*\* \{[^\n]*typecheck[^\n]*blocked-by-fail-fast:lint/.test(failFastStep)) {
	throw new Error('Fail-fast step summary missing compact not-run reason map.');
}
if (!continueFailStep.includes('**Continue on failure:** true') || !continueFailStep.includes('**Dry run:** false') || !continueFailStep.includes('**Exit reason:** completed-with-failures') || !continueFailStep.includes('**Run classification:** failed-continued')) {
	throw new Error('Continue-on-failure failure step summary metadata mismatch.');
}
if (!continueMultiFailStep.includes('**Continue on failure:** true') || !continueMultiFailStep.includes('**Dry run:** false') || !continueMultiFailStep.includes('**Exit reason:** completed-with-failures') || !continueMultiFailStep.includes('**Run classification:** failed-continued')) {
	throw new Error('Continue-on-failure multi-failure step summary metadata mismatch.');
}
if (!continueMultiFailStep.includes('**Failed gates list:** lint, typecheck') || !continueMultiFailStep.includes('**Failed gate exit codes:** 7, 3')) {
	throw new Error('Continue-on-failure multi-failure step summary failed-gate metadata mismatch.');
}
if (!/\*\*Gate attempt-count map:\*\* \{[^\n]*lint[^\n]*2[^\n]*typecheck[^\n]*1/.test(retryStep)) {
	throw new Error('Retry step summary missing attempt-count map.');
}
if (!/\*\*Gate retry-count map:\*\* \{[^\n]*lint[^\n]*1[^\n]*typecheck[^\n]*0/.test(retryStep)) {
	throw new Error('Retry step summary missing retry-count map.');
}
if (!failFastStep.includes('**Log file:** `') || !retryStep.includes('**Log file:** `')) {
	throw new Error('Step summaries should include log-file metadata line.');
}
if (continueFailStep.includes('**Schema warning:**') || continueMultiFailStep.includes('**Schema warning:**') || failFastStep.includes('**Schema warning:**') || retryStep.includes('**Schema warning:**') || continueFlagStep.includes('**Schema warning:**') || dryFallbackStep.includes('**Schema warning:**') || failFastFallbackStep.includes('**Schema warning:**') || fallbackStep.includes('**Schema warning:**')) {
	throw new Error('Did not expect schema warning for current-schema summaries.');
}
if (!continueFlagStep.includes('**Continue on failure:** true') || !continueFlagStep.includes('**Dry run:** true') || !continueFlagStep.includes('**Run classification:** dry-run')) {
	throw new Error('Continue-on-failure dry-run step summary metadata mismatch.');
}
if (!dryFallbackStep.includes('**Gate exit-code map:** {"lint":null}')) {
	throw new Error('Dry fallback summary should derive null exit code for skipped gates.');
}
if (!dryFallbackStep.includes('| `lint` | `make lint` | skip | 0 | 0 | 0 | 0 | n/a | n/a |')) {
	throw new Error('Dry fallback gate row should render non-executed exit code as n/a.');
}
if (!failFastFallbackStep.includes('**Gate exit-code map:** {"lint":7,"typecheck":null}')) {
	throw new Error('Fail-fast fallback summary should preserve executed and non-executed exit code semantics.');
}
if (!failFastFallbackStep.includes('| `typecheck` | `make typecheck` | not-run | 0 | 0 | 0 | 0 | n/a | blocked-by-fail-fast:lint |')) {
	throw new Error('Fail-fast fallback gate row should render blocked gate exit code as n/a.');
}
if (!/\*\*Gate status map:\*\* \{[^\n]*lint[^\n]*pass[^\n]*typecheck[^\n]*pass/.test(fallbackStep)) {
	throw new Error('Fallback summary did not derive gate status map from gate rows.');
}
if (!/\*\*Gate retry-count map:\*\* \{[^\n]*lint[^\n]*1[^\n]*typecheck[^\n]*0/.test(fallbackStep)) {
	throw new Error('Fallback summary did not derive retry-count map from gate rows.');
}
if (!fallbackStep.includes('**Attention gates list:** lint')) {
	throw new Error('Fallback summary did not derive attention-gate list from gate rows.');
}
if (!fallbackStep.includes('**Executed gates list:** lint, typecheck')) {
	throw new Error('Fallback summary did not derive executed-gates list from gate rows.');
}
if (!fallbackStep.includes('**Passed gates list:** lint, typecheck')) {
	throw new Error('Fallback summary did not derive passed-gates list from gate rows.');
}
if (!fallbackStep.includes('**Retried gates:** lint')) {
	throw new Error('Fallback summary did not derive retried-gates list from gate rows.');
}
if (!fallbackStep.includes('**Failed gates list:** none') || !fallbackStep.includes('**Not-run gates list:** none')) {
	throw new Error('Fallback summary did not derive failed/not-run gate lists from gate rows.');
}
NODE

if ! grep -Fq "**Gate count:** 4" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive gate count from gate rows." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive passed gate count." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates:** 1" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive failed gate count." >&2
	exit 1
fi
if ! grep -Fq "**Skipped gates:** 1" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive skipped gate count." >&2
	exit 1
fi
if ! grep -Fq "**Not-run gates:** 1" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive not-run gate count." >&2
	exit 1
fi
if ! grep -Fq "**Status counts:** {\"pass\":1,\"fail\":1,\"skip\":1,\"not-run\":1}" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive statusCounts map from gate rows." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, test-unit, build" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to normalize gate-row IDs when deriving selected-gates list." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass |' "$derived_counts_step_summary" || ! grep -Fq '| `typecheck` | `make typecheck` | fail |' "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary table to normalize gate-row IDs and statuses." >&2
	exit 1
fi
if ! grep -Fq "**Gate not-run reason map:** {\"build\":\"blocked-by-fail-fast:typecheck\"}" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to trim gate-row not-run reason values in reason map output." >&2
	exit 1
fi
if ! grep -Fq '| `build` | `make build` | not-run | 0 | 0 | 0 | 0 | n/a | blocked-by-fail-fast:typecheck |' "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary table to trim gate-row not-run reason values." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive executed gate count from gate rows." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 3s" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive total duration from gate timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T010000Z" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive started timestamp from gate rows." >&2
	exit 1
fi
if ! grep -Fq "**Completed:** 20260215T010003Z" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive completed timestamp from gate rows." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_counts_step_summary"; then
	echo "Did not expect schema warning for derived-count fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to deduplicate normalized row IDs in selected-gates list." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 2" "$duplicate_gate_rows_step_summary" || ! grep -Fq "**Passed gates:** 0" "$duplicate_gate_rows_step_summary" || ! grep -Fq "**Failed gates:** 2" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to keep gate counters aligned with deduplicated normalized row IDs and status precedence." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** none" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to apply fail-over-pass status precedence for duplicate IDs in passed-gates list." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates list:** lint, typecheck" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to apply fail-over-pass status precedence for duplicate IDs in failed-gates list." >&2
	exit 1
fi
if ! grep -Fq "**Gate status map:** {\"lint\":\"fail\",\"typecheck\":\"fail\"}" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to apply fail-over-pass status precedence in gate status map derivation." >&2
	exit 1
fi
if ! grep -Fq "**Gate exit-code map:** {\"lint\":9,\"typecheck\":2}" "$duplicate_gate_rows_step_summary" || ! grep -Fq "**Failed gate exit codes:** 9, 2" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to align failed exit-code derivation with status-precedence-resolved rows." >&2
	exit 1
fi
lint_fail_row_count="$(grep -Fc '| `lint` | `make lint` | fail |' "$duplicate_gate_rows_step_summary")"
if [[ "$lint_fail_row_count" -ne 1 ]] || grep -Fq '| `lint` | `make lint` | pass |' "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary table to render one precedence-resolved lint row only." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates list:** lint, typecheck" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to deduplicate normalized row IDs in executed-gates list." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$duplicate_gate_rows_step_summary"; then
	echo "Did not expect schema warning for duplicate-gate-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 1" "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary to count only normalized valid gate IDs." >&2
	exit 1
fi
if ! grep -Fq "**Status counts:** {\"pass\":1,\"fail\":0,\"skip\":0,\"not-run\":0}" "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary to derive status counts from valid normalized gate rows only." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary to derive selected gate IDs from valid normalized rows only." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass |' "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary table to include normalized valid row." >&2
	exit 1
fi
if grep -Fq '| `unknown` |' "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary table to ignore invalid rows without normalized IDs." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$malformed_gate_rows_step_summary"; then
	echo "Did not expect schema warning for malformed-gate-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate not-run reason map:** none" "$row_not_run_reason_type_step_summary"; then
	echo "Expected row-not-run-reason-type summary to sanitize non-string row not-run reason values to null." >&2
	exit 1
fi
if ! grep -Fq '| `build` | `make build` | not-run | 0 | 0 | 0 | 0 | n/a | n/a |' "$row_not_run_reason_type_step_summary"; then
	echo "Expected row-not-run-reason-type summary table to render non-string not-run reason values as n/a." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$row_not_run_reason_type_step_summary"; then
	echo "Did not expect schema warning for row-not-run-reason-type summary." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `unknown` | pass | 0 | 0 | 0 | 0 | n/a | n/a |' "$row_command_type_step_summary"; then
	echo "Expected row-command-type summary table to sanitize non-string command and invalid numeric row fields." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$row_command_type_step_summary"; then
	echo "Expected row-command-type summary to preserve normalized row ID while sanitizing command value." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$row_command_type_step_summary"; then
	echo "Did not expect schema warning for row-command-type summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$unknown_status_duplicate_rows_step_summary"; then
	echo "Expected unknown-status-duplicate-rows summary to preserve normalized row gate ID selection." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$unknown_status_duplicate_rows_step_summary" || ! grep -Fq "**Failed gates:** 0" "$unknown_status_duplicate_rows_step_summary"; then
	echo "Expected unknown-status-duplicate-rows summary counters to be derived from valid canonical statuses only." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** none" "$unknown_status_duplicate_rows_step_summary"; then
	echo "Expected unknown-status-duplicate-rows summary to avoid marking pass-resolved duplicate IDs as non-success due to invalid duplicate statuses." >&2
	exit 1
fi
if grep -Fq '| `lint` | `make lint` | unknown |' "$unknown_status_duplicate_rows_step_summary"; then
	echo "Expected unknown-status-duplicate-rows summary table to suppress unresolved duplicate row once canonical pass row resolves the gate." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** none" "$unknown_status_duplicate_rows_step_summary"; then
	echo "Expected unknown-status-duplicate-rows summary to avoid attention-list pollution from invalid duplicate statuses." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unknown_status_duplicate_rows_step_summary"; then
	echo "Did not expect schema warning for unknown-status-duplicate-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 1" "$unknown_status_only_rows_step_summary"; then
	echo "Expected unknown-status-only-rows summary to retain selected gate identity for rows with unknown statuses." >&2
	exit 1
fi
if ! grep -Fq "**Gate status map:** {\"lint\":\"unknown\"}" "$unknown_status_only_rows_step_summary"; then
	echo "Expected unknown-status-only-rows summary to render unknown status map entries for unresolved row statuses." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | unknown | 1 | 0 | 0 | 1 | 0 | n/a |' "$unknown_status_only_rows_step_summary"; then
	echo "Expected unknown-status-only-rows summary table to normalize unresolved row statuses to unknown." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint" "$unknown_status_only_rows_step_summary" || ! grep -Fq "**Attention gates list:** lint" "$unknown_status_only_rows_step_summary"; then
	echo "Expected unknown-status-only-rows summary to classify unresolved row statuses as non-success/attention." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unknown_status_only_rows_step_summary"; then
	echo "Did not expect schema warning for unknown-status-only-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 1" "$duplicate_same_status_rows_step_summary" || ! grep -Fq "**Failed gates:** 1" "$duplicate_same_status_rows_step_summary"; then
	echo "Expected duplicate-same-status-rows summary to keep counts deduped by normalized gate ID." >&2
	exit 1
fi
if ! grep -Fq "**Gate exit-code map:** {\"lint\":7}" "$duplicate_same_status_rows_step_summary" || ! grep -Fq "**Failed gate exit codes:** 7" "$duplicate_same_status_rows_step_summary"; then
	echo "Expected duplicate-same-status-rows summary to use last row as deterministic tie-breaker for equal-status duplicates." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | fail | 2 | 1 | 1 | 2 | 7 | n/a |' "$duplicate_same_status_rows_step_summary"; then
	echo "Expected duplicate-same-status-rows summary table to render tie-broken row values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$duplicate_same_status_rows_step_summary"; then
	echo "Did not expect schema warning for duplicate-same-status-rows summary." >&2
	exit 1
fi
selected_order_build_line="$(grep -nF '| `build` | `make build` | pass |' "$selected_order_rows_step_summary" | awk -F: 'NR==1{print $1}')"
selected_order_lint_line="$(grep -nF '| `lint` | `make lint` | pass |' "$selected_order_rows_step_summary" | awk -F: 'NR==1{print $1}')"
if [[ -z "$selected_order_build_line" || -z "$selected_order_lint_line" || "$selected_order_build_line" -ge "$selected_order_lint_line" ]]; then
	echo "Expected selected-order-rows summary table to follow explicit selectedGateIds order when rows are present." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** build, lint" "$selected_order_rows_step_summary"; then
	echo "Expected selected-order-rows summary to normalize explicit selectedGateIds (trim, drop non-strings/empties, dedupe) before rendering." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_order_rows_step_summary"; then
	echo "Did not expect schema warning for selected-order-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** missing, lint" "$selected_order_missing_rows_step_summary"; then
	echo "Expected selected-order-missing-rows summary to preserve explicit selectedGateIds metadata." >&2
	exit 1
fi
if ! grep -Fq "**Gate status map:** {\"missing\":\"unknown\",\"lint\":\"pass\"}" "$selected_order_missing_rows_step_summary"; then
	echo "Expected selected-order-missing-rows summary to default missing selected gates to unknown status in gate status map." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** missing" "$selected_order_missing_rows_step_summary" || ! grep -Fq "**Attention gates list:** missing" "$selected_order_missing_rows_step_summary"; then
	echo "Expected selected-order-missing-rows summary to surface missing selected gates in non-success and attention lists." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":0" "$selected_order_missing_rows_step_summary" || ! grep -Fq "\"missing\":null" "$selected_order_missing_rows_step_summary"; then
	echo "Expected selected-order-missing-rows summary to default missing selected gates to null exit codes in gate exit-code map output." >&2
	exit 1
fi
if ! grep -Fq "\"missing\":0" "$selected_order_missing_rows_step_summary"; then
	echo "Expected selected-order-missing-rows summary to default missing selected gates to zero-valued retry/duration/attempt map entries." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass | 1 | 0 | 0 | 1 | 0 | n/a |' "$selected_order_missing_rows_step_summary" || grep -Fq '| `missing` |' "$selected_order_missing_rows_step_summary" || grep -Fq '| `build` | `make build` |' "$selected_order_missing_rows_step_summary"; then
	echo "Expected selected-order-missing-rows summary table to include only matched selected rows and exclude missing/non-selected rows." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_order_missing_rows_step_summary"; then
	echo "Did not expect schema warning for selected-order-missing-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** missing-only" "$selected_order_unmatched_rows_step_summary"; then
	echo "Expected selected-order-unmatched-rows summary to preserve explicit unmatched selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 0" "$selected_order_unmatched_rows_step_summary" || ! grep -Fq "**Failed gates:** 0" "$selected_order_unmatched_rows_step_summary" || ! grep -Fq "**Executed gates:** 0" "$selected_order_unmatched_rows_step_summary"; then
	echo "Expected selected-order-unmatched-rows summary counters to remain selected-scope based when table rows fall back to available non-selected rows." >&2
	exit 1
fi
if ! grep -Fq "**Gate status map:** {\"missing-only\":\"unknown\"}" "$selected_order_unmatched_rows_step_summary" || ! grep -Fq "**Gate exit-code map:** {\"missing-only\":null}" "$selected_order_unmatched_rows_step_summary"; then
	echo "Expected selected-order-unmatched-rows summary to scope per-gate maps to explicitly selected unmatched gates." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** missing-only" "$selected_order_unmatched_rows_step_summary" || ! grep -Fq "**Attention gates list:** missing-only" "$selected_order_unmatched_rows_step_summary"; then
	echo "Expected selected-order-unmatched-rows summary to keep unmatched selected gates visible in non-success and attention metadata." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass | 1 | 0 | 0 | 1 | 0 | n/a |' "$selected_order_unmatched_rows_step_summary"; then
	echo "Expected selected-order-unmatched-rows summary table to fall back to available rows when selectedGateIds do not match any row IDs." >&2
	exit 1
fi
if grep -Fq '| `n/a` | `n/a` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |' "$selected_order_unmatched_rows_step_summary"; then
	echo "Expected selected-order-unmatched-rows summary table fallback to avoid empty placeholder row when real rows exist." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_order_unmatched_rows_step_summary"; then
	echo "Did not expect schema warning for selected-order-unmatched-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_subset_rows_step_summary" || ! grep -Fq "**Gate count:** 1" "$selected_subset_rows_step_summary"; then
	echo "Expected selected-subset-rows summary to preserve explicit selected subset metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_subset_rows_step_summary" || ! grep -Fq "**Failed gates:** 0" "$selected_subset_rows_step_summary" || ! grep -Fq "**Non-success gates list:** none" "$selected_subset_rows_step_summary"; then
	echo "Expected selected-subset-rows summary to scope pass/fail/non-success derivation to explicitly selected gates only." >&2
	exit 1
fi
if ! grep -Fq "**Gate status map:** {\"lint\":\"pass\"}" "$selected_subset_rows_step_summary" || ! grep -Fq "**Gate exit-code map:** {\"lint\":0}" "$selected_subset_rows_step_summary"; then
	echo "Expected selected-subset-rows summary to scope row-derived per-gate maps to explicitly selected gates only." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":0}" "$selected_subset_rows_step_summary" || ! grep -Fq "**Gate duration map (s):** {\"lint\":1}" "$selected_subset_rows_step_summary" || ! grep -Fq "**Gate attempt-count map:** {\"lint\":1}" "$selected_subset_rows_step_summary"; then
	echo "Expected selected-subset-rows summary to scope row-derived retry/duration/attempt maps to explicitly selected gates only." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass | 1 | 0 | 0 | 1 | 0 | n/a |' "$selected_subset_rows_step_summary" || grep -Fq '| `build` | `make build` |' "$selected_subset_rows_step_summary"; then
	echo "Expected selected-subset-rows summary table to render only rows matching explicit selectedGateIds subset." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_subset_rows_step_summary"; then
	echo "Did not expect schema warning for selected-subset-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** none" "$selected_empty_rows_step_summary" || ! grep -Fq "**Gate count:** 0" "$selected_empty_rows_step_summary"; then
	echo "Expected selected-empty-rows summary to preserve explicit empty selected-gate scope metadata." >&2
	exit 1
fi
if ! grep -Fq "**Gate status map:** {}" "$selected_empty_rows_step_summary" || ! grep -Fq "**Non-success gates list:** none" "$selected_empty_rows_step_summary"; then
	echo "Expected selected-empty-rows summary to keep row-derived maps/lists empty under explicit empty selection." >&2
	exit 1
fi
if ! grep -Fq '| `n/a` | `n/a` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |' "$selected_empty_rows_step_summary"; then
	echo "Expected selected-empty-rows summary table to render placeholder row under explicit empty selection." >&2
	exit 1
fi
if grep -Fq '| `lint` | `make lint` | pass |' "$selected_empty_rows_step_summary"; then
	echo "Expected selected-empty-rows summary table to exclude non-selected rows under explicit empty selection." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_empty_rows_step_summary"; then
	echo "Did not expect schema warning for selected-empty-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Invocation:** unknown" "$invocation_whitespace_step_summary"; then
	echo "Expected invocation-whitespace summary to normalize whitespace-only invocation values to unknown." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invocation_whitespace_step_summary"; then
	echo "Did not expect schema warning for invocation-whitespace summary." >&2
	exit 1
fi
if ! grep -Fq "**Run ID:** unknown" "$metadata_whitespace_step_summary"; then
	echo "Expected metadata-whitespace summary to normalize whitespace-only run ID values to unknown." >&2
	exit 1
fi
if ! grep -Fq "**Result signature algorithm:** unknown" "$metadata_whitespace_step_summary" || ! grep -Fq "**Result signature:** unknown" "$metadata_whitespace_step_summary"; then
	echo "Expected metadata-whitespace summary to normalize whitespace-only signature metadata to unknown." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate:** n/a" "$metadata_whitespace_step_summary" || ! grep -Fq "**Fastest executed gate:** n/a" "$metadata_whitespace_step_summary"; then
	echo "Expected metadata-whitespace summary to normalize blank slow/fast gate IDs to n/a fallback." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate duration:** n/a" "$metadata_whitespace_step_summary" || ! grep -Fq "**Fastest executed gate duration:** n/a" "$metadata_whitespace_step_summary"; then
	echo "Expected metadata-whitespace summary to sanitize invalid slow/fast duration metadata to n/a fallback." >&2
	exit 1
fi
if grep -Fq "**Log file:**" "$metadata_whitespace_step_summary"; then
	echo "Expected metadata-whitespace summary to suppress blank log-file metadata lines." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$metadata_whitespace_step_summary"; then
	echo "Did not expect schema warning for metadata-whitespace summary." >&2
	exit 1
fi
if ! grep -Fq "**Run ID:** unknown" "$metadata_nonstring_step_summary"; then
	echo "Expected metadata-nonstring summary to normalize non-string run ID values to unknown." >&2
	exit 1
fi
if ! grep -Fq "**Result signature algorithm:** unknown" "$metadata_nonstring_step_summary" || ! grep -Fq "**Result signature:** unknown" "$metadata_nonstring_step_summary"; then
	echo "Expected metadata-nonstring summary to normalize non-string signature metadata to unknown." >&2
	exit 1
fi
if grep -Fq "**Log file:**" "$metadata_nonstring_step_summary"; then
	echo "Expected metadata-nonstring summary to suppress non-string log-file metadata lines." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$metadata_nonstring_step_summary"; then
	echo "Did not expect schema warning for metadata-nonstring summary." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate:** lint" "$slow_fast_string_metadata_step_summary" || ! grep -Fq "**Fastest executed gate:** typecheck" "$slow_fast_string_metadata_step_summary"; then
	echo "Expected slow-fast-string-metadata summary to trim slow/fast gate IDs." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate duration:** 5s" "$slow_fast_string_metadata_step_summary" || ! grep -Fq "**Fastest executed gate duration:** 1s" "$slow_fast_string_metadata_step_summary"; then
	echo "Expected slow-fast-string-metadata summary to parse numeric-string slow/fast durations." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$slow_fast_string_metadata_step_summary"; then
	echo "Did not expect schema warning for slow-fast-string-metadata summary." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate:** n/a" "$slow_fast_none_sentinel_metadata_step_summary" || ! grep -Fq "**Fastest executed gate:** n/a" "$slow_fast_none_sentinel_metadata_step_summary"; then
	echo "Expected slow-fast-none-sentinel-metadata summary to ignore scalar slow/fast 'none' sentinels." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate duration:** n/a" "$slow_fast_none_sentinel_metadata_step_summary" || ! grep -Fq "**Fastest executed gate duration:** n/a" "$slow_fast_none_sentinel_metadata_step_summary"; then
	echo "Expected slow-fast-none-sentinel-metadata summary to suppress scalar slow/fast durations when gate IDs resolve to 'none' sentinels." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$slow_fast_none_sentinel_metadata_step_summary"; then
	echo "Did not expect schema warning for slow-fast-none-sentinel-metadata summary." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** none" "$explicit_empty_attention_lists_step_summary" || ! grep -Fq "**Attention gates list:** none" "$explicit_empty_attention_lists_step_summary"; then
	echo "Expected explicit-empty-attention-lists summary to preserve explicit empty non-success/attention lists over row-derived fail status." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates:** 1" "$explicit_empty_attention_lists_step_summary" || ! grep -Fq "**Failed gates list:** lint" "$explicit_empty_attention_lists_step_summary"; then
	echo "Expected explicit-empty-attention-lists summary to keep failure partitions while honoring explicit empty non-success/attention overrides." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_empty_attention_lists_step_summary"; then
	echo "Did not expect schema warning for explicit-empty-attention-lists summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, build" "$explicit_empty_non_success_with_retries_step_summary"; then
	echo "Expected explicit-empty-non-success-with-retries summary to preserve derived sparse gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** none" "$explicit_empty_non_success_with_retries_step_summary"; then
	echo "Expected explicit-empty-non-success-with-retries summary to preserve explicit empty unscoped non-success override." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$explicit_empty_non_success_with_retries_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$explicit_empty_non_success_with_retries_step_summary"; then
	echo "Expected explicit-empty-non-success-with-retries summary to preserve explicit retried metadata alongside empty non-success override." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 2" "$explicit_empty_non_success_with_retries_step_summary" || ! grep -Fq "**Total retry backoff:** 3s" "$explicit_empty_non_success_with_retries_step_summary"; then
	echo "Expected explicit-empty-non-success-with-retries summary to derive retry aggregates from explicit retried evidence." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$explicit_empty_non_success_with_retries_step_summary"; then
	echo "Expected explicit-empty-non-success-with-retries summary to include retried gate in attention fallback when only non-success list is explicitly empty." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_empty_non_success_with_retries_step_summary"; then
	echo "Did not expect schema warning for explicit-empty-non-success-with-retries summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, build" "$explicit_empty_attention_with_retries_step_summary"; then
	echo "Expected explicit-empty-attention-with-retries summary to preserve derived sparse gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** none" "$explicit_empty_attention_with_retries_step_summary"; then
	echo "Expected explicit-empty-attention-with-retries summary to preserve explicit empty unscoped attention override." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$explicit_empty_attention_with_retries_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$explicit_empty_attention_with_retries_step_summary"; then
	echo "Expected explicit-empty-attention-with-retries summary to preserve explicit retried metadata while attention override is empty." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 2" "$explicit_empty_attention_with_retries_step_summary" || ! grep -Fq "**Total retry backoff:** 3s" "$explicit_empty_attention_with_retries_step_summary"; then
	echo "Expected explicit-empty-attention-with-retries summary to derive retry aggregates from explicit retried evidence." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** none" "$explicit_empty_attention_with_retries_step_summary"; then
	echo "Expected explicit-empty-attention-with-retries summary to keep non-success list clear for pass-only statuses." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_empty_attention_with_retries_step_summary"; then
	echo "Did not expect schema warning for explicit-empty-attention-with-retries summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_status_map_scope_step_summary" || ! grep -Fq "**Gate count:** 1" "$selected_status_map_scope_step_summary"; then
	echo "Expected selected-status-map-scope summary to keep explicit selected gate scope metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_status_map_scope_step_summary" || ! grep -Fq "**Failed gates:** 0" "$selected_status_map_scope_step_summary"; then
	echo "Expected selected-status-map-scope summary to scope derived pass/fail counters to selected IDs when using status-map fallback." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {"lint":"pass"}' "$selected_status_map_scope_step_summary"; then
	echo "Expected selected-status-map-scope summary to filter summary gate-status map entries to selected IDs." >&2
	exit 1
fi
if ! grep -Fq '**Gate exit-code map:** {"lint":0}' "$selected_status_map_scope_step_summary"; then
	echo "Expected selected-status-map-scope summary to filter summary exit-code map entries to selected IDs." >&2
	exit 1
fi
if ! grep -Fq '**Gate retry-count map:** {"lint":0}' "$selected_status_map_scope_step_summary" || ! grep -Fq '**Gate duration map (s):** {"lint":1}' "$selected_status_map_scope_step_summary" || ! grep -Fq '**Gate attempt-count map:** {"lint":1}' "$selected_status_map_scope_step_summary"; then
	echo "Expected selected-status-map-scope summary to filter summary retry/duration/attempt maps to selected IDs." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** none" "$selected_status_map_scope_step_summary" || ! grep -Fq "**Attention gates list:** none" "$selected_status_map_scope_step_summary"; then
	echo "Expected selected-status-map-scope summary to derive non-success/attention lists from selected-scope status-map data." >&2
	exit 1
fi
if grep -Fq "build" "$selected_status_map_scope_step_summary"; then
	echo "Expected selected-status-map-scope summary to exclude non-selected status-map gate IDs from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_status_counts_conflict_status_map_scope_step_summary" || ! grep -Fq "**Gate count:** 2" "$selected_status_counts_conflict_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-conflict-status-map-scope summary to preserve selected scope metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_status_counts_conflict_status_map_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_status_counts_conflict_status_map_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_status_counts_conflict_status_map_scope_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$selected_status_counts_conflict_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-conflict-status-map-scope summary to ignore conflicting scalar/raw counters and derive selected counts from status-map evidence." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":0,"not-run":0}' "$selected_status_counts_conflict_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-conflict-status-map-scope summary to align status counts with selected status-map evidence despite conflicting raw statusCounts." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_status_counts_conflict_status_map_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_status_counts_conflict_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-conflict-status-map-scope summary to derive selected executed/pass-rate metadata from status-map evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_counts_conflict_status_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-counts-conflict-status-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, docs" "$selected_status_counts_partial_malformed_status_map_scope_step_summary" || ! grep -Fq "**Gate count:** 3" "$selected_status_counts_partial_malformed_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-malformed-status-map-scope summary to preserve selected scope metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_status_counts_partial_malformed_status_map_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_status_counts_partial_malformed_status_map_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_status_counts_partial_malformed_status_map_scope_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$selected_status_counts_partial_malformed_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-malformed-status-map-scope summary to suppress mixed scalar/raw status-count conflicts and derive selected counters from status-map evidence." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":0,"not-run":1}' "$selected_status_counts_partial_malformed_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-malformed-status-map-scope summary to align status counts with selected status-map evidence despite partially malformed raw statusCounts." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_status_counts_partial_malformed_status_map_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_status_counts_partial_malformed_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-malformed-status-map-scope summary to derive selected executed/pass-rate metadata from status-map evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_counts_partial_malformed_status_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-counts-partial-malformed-status-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_status_counts_zero_raw_status_map_scope_step_summary" || ! grep -Fq "**Gate count:** 2" "$selected_status_counts_zero_raw_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-status-map-scope summary to preserve selected scope metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_status_counts_zero_raw_status_map_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_status_counts_zero_raw_status_map_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_status_counts_zero_raw_status_map_scope_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$selected_status_counts_zero_raw_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-status-map-scope summary to ignore explicit zero selected scalar/raw counters and derive selected status counts from status-map evidence." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":0,"not-run":0}' "$selected_status_counts_zero_raw_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-status-map-scope summary to keep selected status counts aligned with status-map evidence despite explicit zero raw statusCounts." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_status_counts_zero_raw_status_map_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_status_counts_zero_raw_status_map_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-status-map-scope summary to derive selected executed/pass-rate metadata from status-map evidence under explicit zero scalar/raw count conflicts." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_counts_zero_raw_status_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-counts-zero-raw-status-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Gate count:** 3" "$selected_status_counts_partial_status_map_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-status-map-partition-scope summary to preserve selected scope metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$selected_status_counts_partial_status_map_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-status-map-partition-scope summary to merge partial selected status-map and partition evidence while ignoring conflicting selected scalar/raw count inputs." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":0,"not-run":1}' "$selected_status_counts_partial_status_map_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-status-map-partition-scope summary to align status counts with merged selected status-map and partition evidence." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {"lint":"pass"}' "$selected_status_counts_partial_status_map_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-status-map-partition-scope summary to keep explicitly provided selected status-map metadata sparse while partition fallback fills missing counters." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** lint" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Failed gates list:** typecheck" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Not-run gates list:** build" "$selected_status_counts_partial_status_map_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-status-map-partition-scope summary to preserve selected partition labels derived from mixed status-map/list evidence." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Executed gates list:** lint, typecheck" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_status_counts_partial_status_map_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-status-map-partition-scope summary to merge partial selected status-map/partition evidence for executed and pass-rate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck, build" "$selected_status_counts_partial_status_map_partition_scope_step_summary" || ! grep -Fq "**Attention gates list:** typecheck, build" "$selected_status_counts_partial_status_map_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-status-map-partition-scope summary to keep non-success and attention derivation aligned with selected mixed status-map/partition evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_counts_partial_status_map_partition_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-counts-partial-status-map-partition-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_scalar_failure_scope_step_summary" || ! grep -Fq "**Passed gates:** 1" "$selected_scalar_failure_scope_step_summary" || ! grep -Fq "**Failed gates:** 0" "$selected_scalar_failure_scope_step_summary"; then
	echo "Expected selected-scalar-failure-scope summary to keep partition counts scoped to selected IDs." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** none" "$selected_scalar_failure_scope_step_summary" || ! grep -Fq "**Failed gate exit code:** none" "$selected_scalar_failure_scope_step_summary"; then
	echo "Expected selected-scalar-failure-scope summary to suppress non-selected scalar failed-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$selected_scalar_failure_scope_step_summary"; then
	echo "Expected selected-scalar-failure-scope summary to suppress non-selected blocked-by gate metadata." >&2
	exit 1
fi
if grep -Fq "build" "$selected_scalar_failure_scope_step_summary"; then
	echo "Expected selected-scalar-failure-scope summary to exclude non-selected scalar failure gate IDs from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_scalar_failure_scope_step_summary"; then
	echo "Did not expect schema warning for selected-scalar-failure-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_scalar_counts_scope_step_summary" || ! grep -Fq "**Gate count:** 1" "$selected_scalar_counts_scope_step_summary"; then
	echo "Expected selected-scalar-counts-scope summary to prioritize selected gate-count scope over conflicting scalar gateCount." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_scalar_counts_scope_step_summary" || ! grep -Fq "**Failed gates:** 0" "$selected_scalar_counts_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_scalar_counts_scope_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$selected_scalar_counts_scope_step_summary"; then
	echo "Expected selected-scalar-counts-scope summary to ignore conflicting scalar pass/fail/skip/not-run counts when selected scope is explicit." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":0,"skip":0,"not-run":0}' "$selected_scalar_counts_scope_step_summary"; then
	echo "Expected selected-scalar-counts-scope summary to derive status counts from selected-scope partitions instead of conflicting raw statusCounts." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 1" "$selected_scalar_counts_scope_step_summary"; then
	echo "Expected selected-scalar-counts-scope summary to ignore conflicting scalar executedGateCount when selected scope is explicit." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_scalar_counts_scope_step_summary"; then
	echo "Did not expect schema warning for selected-scalar-counts-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_status_counts_no_evidence_scope_step_summary" || ! grep -Fq "**Gate count:** 2" "$selected_status_counts_no_evidence_scope_step_summary"; then
	echo "Expected selected-status-counts-no-evidence-scope summary to preserve explicit selected scope metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 0" "$selected_status_counts_no_evidence_scope_step_summary" || ! grep -Fq "**Failed gates:** 0" "$selected_status_counts_no_evidence_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_status_counts_no_evidence_scope_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$selected_status_counts_no_evidence_scope_step_summary"; then
	echo "Expected selected-status-counts-no-evidence-scope summary to ignore selected-scope scalar and raw status-count counters when no selected execution evidence exists." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":0,"fail":0,"skip":0,"not-run":0}' "$selected_status_counts_no_evidence_scope_step_summary"; then
	echo "Expected selected-status-counts-no-evidence-scope summary to keep status counts aligned with selected no-evidence fallback counters." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 0" "$selected_status_counts_no_evidence_scope_step_summary" || ! grep -Fq "**Executed gates list:** none" "$selected_status_counts_no_evidence_scope_step_summary"; then
	echo "Expected selected-status-counts-no-evidence-scope summary to keep executed metadata empty under selected no-evidence payloads." >&2
	exit 1
fi
if ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_status_counts_no_evidence_scope_step_summary" || ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_status_counts_no_evidence_scope_step_summary"; then
	echo "Expected selected-status-counts-no-evidence-scope summary to render executed-rate metrics as n/a under selected no-evidence payloads." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_counts_no_evidence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-counts-no-evidence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, deploy" "$selected_status_counts_conflict_partition_scope_step_summary" || ! grep -Fq "**Gate count:** 4" "$selected_status_counts_conflict_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-conflict-partition-scope summary to preserve selected-scope gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_status_counts_conflict_partition_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_status_counts_conflict_partition_scope_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$selected_status_counts_conflict_partition_scope_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$selected_status_counts_conflict_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-conflict-partition-scope summary to ignore conflicting raw statusCounts and derive selected counters from scoped partition evidence." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":1,"not-run":1}' "$selected_status_counts_conflict_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-conflict-partition-scope summary to align selected status counts with scoped partition evidence instead of conflicting raw statusCounts." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_status_counts_conflict_partition_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_status_counts_conflict_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-conflict-partition-scope summary to derive selected executed/pass-rate metadata from scoped partition evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_counts_conflict_partition_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-counts-conflict-partition-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, deploy" "$selected_scalar_raw_count_mix_partition_scope_step_summary" || ! grep -Fq "**Gate count:** 4" "$selected_scalar_raw_count_mix_partition_scope_step_summary"; then
	echo "Expected selected-scalar-raw-count-mix-partition-scope summary to preserve selected scope gate metadata over conflicting scalar gateCount." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_scalar_raw_count_mix_partition_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_scalar_raw_count_mix_partition_scope_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$selected_scalar_raw_count_mix_partition_scope_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$selected_scalar_raw_count_mix_partition_scope_step_summary"; then
	echo "Expected selected-scalar-raw-count-mix-partition-scope summary to ignore mixed scalar/raw status counters and derive selected partition counts from scoped lists." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":1,"not-run":1}' "$selected_scalar_raw_count_mix_partition_scope_step_summary"; then
	echo "Expected selected-scalar-raw-count-mix-partition-scope summary to keep selected status counts aligned with scoped partition evidence despite mixed scalar/raw conflicts." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_scalar_raw_count_mix_partition_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_scalar_raw_count_mix_partition_scope_step_summary"; then
	echo "Expected selected-scalar-raw-count-mix-partition-scope summary to derive executed/pass-rate metadata from scoped selected partition evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_scalar_raw_count_mix_partition_scope_step_summary"; then
	echo "Did not expect schema warning for selected-scalar-raw-count-mix-partition-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, deploy" "$selected_status_counts_partial_malformed_partition_scope_step_summary" || ! grep -Fq "**Gate count:** 4" "$selected_status_counts_partial_malformed_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-malformed-partition-scope summary to preserve selected scope gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_status_counts_partial_malformed_partition_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_status_counts_partial_malformed_partition_scope_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$selected_status_counts_partial_malformed_partition_scope_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$selected_status_counts_partial_malformed_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-malformed-partition-scope summary to ignore partially malformed raw statusCounts under explicit selected partition scope." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":1,"not-run":1}' "$selected_status_counts_partial_malformed_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-malformed-partition-scope summary to keep selected status counts aligned with scoped partition evidence despite partial raw statusCounts values." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_status_counts_partial_malformed_partition_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_status_counts_partial_malformed_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-partial-malformed-partition-scope summary to derive selected executed/pass-rate metadata from scoped partition evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_counts_partial_malformed_partition_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-counts-partial-malformed-partition-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, deploy" "$selected_status_counts_zero_raw_partition_scope_step_summary" || ! grep -Fq "**Gate count:** 4" "$selected_status_counts_zero_raw_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-partition-scope summary to preserve selected scope gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_status_counts_zero_raw_partition_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_status_counts_zero_raw_partition_scope_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$selected_status_counts_zero_raw_partition_scope_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$selected_status_counts_zero_raw_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-partition-scope summary to ignore explicit zero raw statusCounts and derive selected counters from scoped partition evidence." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":1,"not-run":1}' "$selected_status_counts_zero_raw_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-partition-scope summary to align selected status counts with scoped partition evidence despite explicit zero raw statusCounts." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_status_counts_zero_raw_partition_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_status_counts_zero_raw_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-partition-scope summary to derive selected executed/pass-rate metadata from scoped partition evidence under explicit zero raw statusCounts conflict." >&2
	exit 1
fi
if grep -Fq '**Status counts:** {"pass":0,' "$selected_status_counts_zero_raw_partition_scope_step_summary"; then
	echo "Expected selected-status-counts-zero-raw-partition-scope summary to prevent explicit zero raw statusCounts from overriding selected partition-scoped status-count metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_status_counts_zero_raw_partition_scope_step_summary"; then
	echo "Did not expect schema warning for selected-status-counts-zero-raw-partition-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_failed_exit_code_alignment_step_summary" || ! grep -Fq "**Failed gates list:** lint" "$selected_failed_exit_code_alignment_step_summary"; then
	echo "Expected selected-failed-exit-code-alignment summary to preserve selected-scope failed gate identity." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit codes:** 2" "$selected_failed_exit_code_alignment_step_summary" || ! grep -Fq '**Gate exit-code map:** {"lint":2}' "$selected_failed_exit_code_alignment_step_summary"; then
	echo "Expected selected-failed-exit-code-alignment summary to align failed gate exit codes by selected gate ID, not original unscoped list position." >&2
	exit 1
fi
if grep -Fq "9" "$selected_failed_exit_code_alignment_step_summary" || grep -Fq "build" "$selected_failed_exit_code_alignment_step_summary"; then
	echo "Expected selected-failed-exit-code-alignment summary to exclude non-selected failed-gate IDs/exit codes from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_failed_exit_code_alignment_step_summary"; then
	echo "Did not expect schema warning for selected-failed-exit-code-alignment summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_slow_fast_scope_step_summary"; then
	echo "Expected selected-slow-fast-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate:** lint" "$selected_slow_fast_scope_step_summary" || ! grep -Fq "**Fastest executed gate:** lint" "$selected_slow_fast_scope_step_summary"; then
	echo "Expected selected-slow-fast-scope summary to ignore non-selected explicit slow/fast gate IDs and fall back to selected-scope derived values." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate duration:** 3s" "$selected_slow_fast_scope_step_summary" || ! grep -Fq "**Fastest executed gate duration:** 3s" "$selected_slow_fast_scope_step_summary"; then
	echo "Expected selected-slow-fast-scope summary to ignore non-selected explicit slow/fast durations and use selected-scope derived durations." >&2
	exit 1
fi
if grep -Fq "build" "$selected_slow_fast_scope_step_summary" || grep -Fq "9s" "$selected_slow_fast_scope_step_summary"; then
	echo "Expected selected-slow-fast-scope summary to exclude non-selected explicit slow/fast metadata from rendered output." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_slow_fast_scope_step_summary"; then
	echo "Did not expect schema warning for selected-slow-fast-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$selected_aggregate_metrics_scope_step_summary" || ! grep -Fq "**Total retries:** 0" "$selected_aggregate_metrics_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$selected_aggregate_metrics_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scope summary to ignore conflicting aggregate retry scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 4s" "$selected_aggregate_metrics_scope_step_summary" || ! grep -Fq "**Executed duration average:** 4s" "$selected_aggregate_metrics_scope_step_summary" || ! grep -Fq "**Total duration:** 4s" "$selected_aggregate_metrics_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scope summary to ignore conflicting aggregate duration scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 0%" "$selected_aggregate_metrics_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 0%" "$selected_aggregate_metrics_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scope summary to ignore conflicting aggregate rate scalars under explicit selected scope." >&2
	exit 1
fi
if grep -Fq "99" "$selected_aggregate_metrics_scope_step_summary" || grep -Fq "200" "$selected_aggregate_metrics_scope_step_summary" || grep -Fq "80%" "$selected_aggregate_metrics_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scope summary to exclude conflicting unscoped aggregate scalar values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_string_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-string-scalar-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$selected_aggregate_metrics_string_scalar_scope_step_summary" || ! grep -Fq "**Total retries:** 1" "$selected_aggregate_metrics_string_scalar_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_aggregate_metrics_string_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-string-scalar-scope summary to ignore numeric-string aggregate retry scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 4s" "$selected_aggregate_metrics_string_scalar_scope_step_summary" || ! grep -Fq "**Executed duration average:** 4s" "$selected_aggregate_metrics_string_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-string-scalar-scope summary to ignore numeric-string aggregate duration scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_string_scalar_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 25%" "$selected_aggregate_metrics_string_scalar_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_string_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-string-scalar-scope summary to ignore numeric-string aggregate rate scalars under explicit selected scope." >&2
	exit 1
fi
if grep -Fq "99" "$selected_aggregate_metrics_string_scalar_scope_step_summary" || grep -Fq "80%" "$selected_aggregate_metrics_string_scalar_scope_step_summary" || grep -Fq "8s" "$selected_aggregate_metrics_string_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-string-scalar-scope summary to suppress conflicting numeric-string aggregate scalar values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_string_scalar_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-string-scalar-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_decimal_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-decimal-string-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$selected_aggregate_metrics_decimal_string_scope_step_summary" || ! grep -Fq "**Total retries:** 1" "$selected_aggregate_metrics_decimal_string_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_aggregate_metrics_decimal_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-decimal-string-scope summary to ignore decimal-string aggregate retry scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 4s" "$selected_aggregate_metrics_decimal_string_scope_step_summary" || ! grep -Fq "**Executed duration average:** 4s" "$selected_aggregate_metrics_decimal_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-decimal-string-scope summary to ignore decimal-string aggregate duration scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_decimal_string_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 25%" "$selected_aggregate_metrics_decimal_string_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_decimal_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-decimal-string-scope summary to ignore decimal-string aggregate rate scalars under explicit selected scope." >&2
	exit 1
fi
if grep -Fq "99.5" "$selected_aggregate_metrics_decimal_string_scope_step_summary" || grep -Fq "80.5%" "$selected_aggregate_metrics_decimal_string_scope_step_summary" || grep -Fq "8.5" "$selected_aggregate_metrics_decimal_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-decimal-string-scope summary to suppress conflicting decimal-string aggregate scalar values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_decimal_string_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-decimal-string-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_scientific_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scientific-string-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$selected_aggregate_metrics_scientific_string_scope_step_summary" || ! grep -Fq "**Total retries:** 1" "$selected_aggregate_metrics_scientific_string_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_aggregate_metrics_scientific_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scientific-string-scope summary to ignore scientific-notation aggregate retry scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 4s" "$selected_aggregate_metrics_scientific_string_scope_step_summary" || ! grep -Fq "**Executed duration average:** 4s" "$selected_aggregate_metrics_scientific_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scientific-string-scope summary to ignore scientific-notation aggregate duration scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_scientific_string_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 25%" "$selected_aggregate_metrics_scientific_string_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_scientific_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scientific-string-scope summary to ignore scientific-notation aggregate rate scalars under explicit selected scope." >&2
	exit 1
fi
if grep -Fq "99e1" "$selected_aggregate_metrics_scientific_string_scope_step_summary" || grep -Fq "80e1" "$selected_aggregate_metrics_scientific_string_scope_step_summary" || grep -Fq "8e1" "$selected_aggregate_metrics_scientific_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-scientific-string-scope summary to suppress conflicting scientific-notation aggregate scalar values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_scientific_string_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-scientific-string-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_float_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-float-scalar-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$selected_aggregate_metrics_float_scalar_scope_step_summary" || ! grep -Fq "**Total retries:** 1" "$selected_aggregate_metrics_float_scalar_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_aggregate_metrics_float_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-float-scalar-scope summary to ignore non-integer numeric aggregate retry scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 4s" "$selected_aggregate_metrics_float_scalar_scope_step_summary" || ! grep -Fq "**Executed duration average:** 4s" "$selected_aggregate_metrics_float_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-float-scalar-scope summary to ignore non-integer numeric aggregate duration scalars under explicit selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_float_scalar_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 25%" "$selected_aggregate_metrics_float_scalar_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_float_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-float-scalar-scope summary to ignore non-integer numeric aggregate rate scalars under explicit selected scope." >&2
	exit 1
fi
if grep -Fq "99.5" "$selected_aggregate_metrics_float_scalar_scope_step_summary" || grep -Fq "80.5%" "$selected_aggregate_metrics_float_scalar_scope_step_summary" || grep -Fq "8.5" "$selected_aggregate_metrics_float_scalar_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-float-scalar-scope summary to suppress conflicting non-integer numeric aggregate scalar values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_float_scalar_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-float-scalar-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-overflow-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 25%" "$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-overflow-scope summary to ignore overflow selected aggregate rate scalars and derive selected rates from selected-scope evidence." >&2
	exit 1
fi
if grep -Fq "150%" "$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary" || grep -Fq "140%" "$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary" || grep -Fq "120%" "$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-overflow-scope summary to suppress overflow selected aggregate rate scalar literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_rate_scalar_overflow_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-rate-scalar-overflow-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-boundary-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 25%" "$selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-boundary-scope summary to keep selected-scope rate derivation authoritative even when explicit selected rate scalars are valid boundaries." >&2
	exit 1
fi
if grep -Fq "**Retry rate (executed gates):** 0%" "$selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary" || grep -Fq "**Pass rate (executed gates):** 0%" "$selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-boundary-scope summary to avoid preserving explicit selected boundary rate scalars over selected evidence-derived rates." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_rate_scalar_boundary_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-rate-scalar-boundary-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 25%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-scope summary to keep selected evidence-derived rates authoritative when selected boundary and overflow rate scalars are mixed." >&2
	exit 1
fi
if grep -Fq "**Retry rate (executed gates):** 0%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary" || grep -Fq "101%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-scope summary to suppress mixed boundary/overflow selected rate scalar literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-rate-scalar-mixed-boundary-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_malformed_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-malformed-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$selected_aggregate_metrics_malformed_scope_step_summary" || ! grep -Fq "**Total retries:** 1" "$selected_aggregate_metrics_malformed_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_aggregate_metrics_malformed_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-malformed-scope summary to ignore malformed aggregate retry scalars and derive retries from selected retry-count map evidence." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 4s" "$selected_aggregate_metrics_malformed_scope_step_summary" || ! grep -Fq "**Executed duration average:** 4s" "$selected_aggregate_metrics_malformed_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-malformed-scope summary to ignore malformed aggregate duration scalars and derive executed-duration metrics from selected duration-map evidence." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_malformed_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 25%" "$selected_aggregate_metrics_malformed_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_aggregate_metrics_malformed_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-malformed-scope summary to ignore malformed aggregate rate scalars and derive rates from selected counts/durations." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_malformed_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-malformed-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$selected_aggregate_metrics_no_evidence_scope_step_summary" || ! grep -Fq "**Total retries:** 0" "$selected_aggregate_metrics_no_evidence_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$selected_aggregate_metrics_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-scope summary to ignore conflicting selected aggregate retry scalars when selected retry evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 0s" "$selected_aggregate_metrics_no_evidence_scope_step_summary" || ! grep -Fq "**Executed duration average:** n/a" "$selected_aggregate_metrics_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-scope summary to ignore conflicting selected aggregate duration scalars when selected duration evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_aggregate_metrics_no_evidence_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$selected_aggregate_metrics_no_evidence_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_aggregate_metrics_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-scope summary to ignore conflicting selected aggregate rate scalars and render n/a without selected execution evidence." >&2
	exit 1
fi
if grep -Fq "99" "$selected_aggregate_metrics_no_evidence_scope_step_summary" || grep -Fq "80%" "$selected_aggregate_metrics_no_evidence_scope_step_summary" || grep -Fq "8s" "$selected_aggregate_metrics_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-scope summary to exclude conflicting selected aggregate scalar values without selected execution evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_no_evidence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-no-evidence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-overflow-no-evidence-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-overflow-no-evidence-scope summary to reject overflow selected rate scalars and keep selected no-evidence rate fallbacks at n/a." >&2
	exit 1
fi
if grep -Fq "150%" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary" || grep -Fq "140%" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary" || grep -Fq "120%" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-overflow-no-evidence-scope summary to suppress overflow selected rate scalar literals in sparse no-evidence payloads." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_rate_scalar_overflow_no_evidence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-rate-scalar-overflow-no-evidence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-scope summary to keep selected no-evidence rate fallbacks at n/a despite mixed boundary/overflow selected rate scalars." >&2
	exit 1
fi
if grep -Fq "101%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary" || grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary" || grep -Fq "**Pass rate (executed gates):** 0%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-scope summary to suppress boundary and overflow selected rate scalar literals without selected execution evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-string-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-string-scope summary to keep selected no-evidence rate fallbacks at n/a for mixed boundary/overflow numeric-string scalars." >&2
	exit 1
fi
if grep -Fq "101%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary" || grep -Fq "**Retry rate (executed gates):** 100%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary" || grep -Fq "**Pass rate (executed gates):** 0%" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-string-scope summary to suppress boundary and overflow numeric-string selected rate scalar literals without selected execution evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_string_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-string-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-nonselected-evidence-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 0" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" || ! grep -Fq "**Retried gates:** none" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-nonselected-evidence-scope summary to scope out non-selected execution/retry evidence." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" || ! grep -Fq "**Total retries:** 0" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-nonselected-evidence-scope summary to ignore non-selected retry evidence and conflicting selected aggregate retry scalars." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 0s" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" || ! grep -Fq "**Executed duration average:** n/a" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-nonselected-evidence-scope summary to ignore non-selected duration evidence and conflicting selected aggregate duration scalars." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-nonselected-evidence-scope summary to ignore non-selected execution evidence and conflicting selected aggregate rate scalars." >&2
	exit 1
fi
if grep -Fq "build" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" || grep -Fq "99" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary" || grep -Fq "80%" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-nonselected-evidence-scope summary to suppress non-selected evidence and conflicting selected aggregate scalar values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_nonselected_evidence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-nonselected-evidence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-string-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary" || ! grep -Fq "**Total retries:** 0" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-string-scope summary to ignore numeric-string selected aggregate retry scalars when selected retry evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 0s" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary" || ! grep -Fq "**Executed duration average:** n/a" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-string-scope summary to ignore numeric-string selected aggregate duration scalars when selected duration evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-string-scope summary to ignore numeric-string selected aggregate rate scalars without selected execution evidence." >&2
	exit 1
fi
if grep -Fq "99" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary" || grep -Fq "80%" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary" || grep -Fq "8s" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-string-scope summary to suppress numeric-string selected aggregate scalar values when selected evidence is absent." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_no_evidence_string_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-no-evidence-string-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-plus-string-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary" || ! grep -Fq "**Total retries:** 0" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-plus-string-scope summary to ignore plus-prefixed selected aggregate retry scalars when selected retry evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 0s" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary" || ! grep -Fq "**Executed duration average:** n/a" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-plus-string-scope summary to ignore plus-prefixed selected aggregate duration scalars when selected duration evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-plus-string-scope summary to ignore plus-prefixed selected aggregate rate scalars without selected execution evidence." >&2
	exit 1
fi
if grep -Fq "+99" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary" || grep -Fq "+80%" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary" || grep -Fq "+8" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-plus-string-scope summary to suppress plus-prefixed selected aggregate scalar values when selected evidence is absent." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_no_evidence_plus_string_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-no-evidence-plus-string-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-mixed-invalid-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || ! grep -Fq "**Total retries:** 0" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-mixed-invalid-scope summary to ignore mixed invalid selected aggregate retry scalars when selected retry evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 0s" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || ! grep -Fq "**Executed duration average:** n/a" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-mixed-invalid-scope summary to ignore mixed invalid selected aggregate duration scalars when selected duration evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-mixed-invalid-scope summary to ignore mixed invalid selected aggregate rate scalars without selected execution evidence." >&2
	exit 1
fi
if grep -Fq "8.5" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || grep -Fq "8e1" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || grep -Fq "99.5" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || grep -Fq "99e1" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || grep -Fq "80.5" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary" || grep -Fq "80e1" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary"; then
	echo "Expected selected-aggregate-metrics-no-evidence-mixed-invalid-scope summary to suppress mixed invalid selected aggregate scalar literals when selected evidence is absent." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_aggregate_metrics_no_evidence_mixed_invalid_scope_step_summary"; then
	echo "Did not expect schema warning for selected-aggregate-metrics-no-evidence-mixed-invalid-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_failed_exit_codes_without_ids_scope_step_summary" || ! grep -Fq "**Failed gates list:** lint" "$selected_failed_exit_codes_without_ids_scope_step_summary"; then
	echo "Expected selected-failed-exit-codes-without-ids-scope summary to preserve selected-scope failed gate identity." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit codes:** 2" "$selected_failed_exit_codes_without_ids_scope_step_summary" || ! grep -Fq '**Gate exit-code map:** {"lint":2}' "$selected_failed_exit_codes_without_ids_scope_step_summary"; then
	echo "Expected selected-failed-exit-codes-without-ids-scope summary to ignore ambiguous failedGateExitCodes list without failedGateIds under selected scope." >&2
	exit 1
fi
if grep -Fq "9" "$selected_failed_exit_codes_without_ids_scope_step_summary"; then
	echo "Expected selected-failed-exit-codes-without-ids-scope summary to suppress ambiguous unscoped failedGateExitCodes values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_failed_exit_codes_without_ids_scope_step_summary"; then
	echo "Did not expect schema warning for selected-failed-exit-codes-without-ids-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_scope_step_summary"; then
	echo "Expected selected-timestamps-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T100000Z" "$selected_timestamps_scope_step_summary" || ! grep -Fq "**Completed:** 20260215T100003Z" "$selected_timestamps_scope_step_summary"; then
	echo "Expected selected-timestamps-scope summary to ignore unscoped explicit started/completed timestamps under selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 3s" "$selected_timestamps_scope_step_summary"; then
	echo "Expected selected-timestamps-scope summary to derive total duration from selected-scope timestamps/durations." >&2
	exit 1
fi
if grep -Fq "20250101T000000Z" "$selected_timestamps_scope_step_summary" || grep -Fq "20250101T000010Z" "$selected_timestamps_scope_step_summary"; then
	echo "Expected selected-timestamps-scope summary to suppress non-selected explicit start/completion metadata values." >&2
	exit 1
fi
if grep -Fq "20260215T090000Z" "$selected_timestamps_scope_step_summary" || grep -Fq "20260215T090008Z" "$selected_timestamps_scope_step_summary"; then
	echo "Expected selected-timestamps-scope summary to ignore non-selected gate-row timestamps during selected-scope derivation." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T110000Z" "$selected_timestamps_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20260215T110005Z" "$selected_timestamps_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-no-rows-scope summary to preserve explicit selected-scope start/completion timestamps when no rows exist." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 5s" "$selected_timestamps_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-no-rows-scope summary to derive total duration from explicit selected-scope start/completion timestamps when no rows exist." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_invalid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$selected_timestamps_invalid_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** unknown" "$selected_timestamps_invalid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-no-rows-scope summary to suppress malformed explicit timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$selected_timestamps_invalid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-no-rows-scope summary to render unknown total duration when malformed timestamps are unresolvable." >&2
	exit 1
fi
if grep -Fq "20260230T110000Z" "$selected_timestamps_invalid_no_rows_scope_step_summary" || grep -Fq "20260230T110005Z" "$selected_timestamps_invalid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-no-rows-scope summary to ignore malformed explicit timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_invalid_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-invalid-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_leap_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-leap-valid-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20240229T110000Z" "$selected_timestamps_leap_valid_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20240229T110005Z" "$selected_timestamps_leap_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-leap-valid-no-rows-scope summary to preserve valid leap-day timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 5s" "$selected_timestamps_leap_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-leap-valid-no-rows-scope summary to derive duration from valid leap-day timestamps." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_leap_valid_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-leap-valid-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-nonleap-century-invalid-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** unknown" "$selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-nonleap-century-invalid-no-rows-scope summary to suppress invalid non-leap-century timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-nonleap-century-invalid-no-rows-scope summary to render unknown duration for invalid non-leap-century timestamps." >&2
	exit 1
fi
if grep -Fq "19000229T110000Z" "$selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary" || grep -Fq "19000229T110005Z" "$selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-nonleap-century-invalid-no-rows-scope summary to ignore invalid non-leap-century timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_nonleap_century_invalid_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-nonleap-century-invalid-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_century_leap_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-century-leap-valid-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20000229T110000Z" "$selected_timestamps_century_leap_valid_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20000229T110005Z" "$selected_timestamps_century_leap_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-century-leap-valid-no-rows-scope summary to preserve valid century leap-day timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 5s" "$selected_timestamps_century_leap_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-century-leap-valid-no-rows-scope summary to derive duration from valid century leap-day timestamps." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_century_leap_valid_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-century-leap-valid-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_invalid_second_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-second-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$selected_timestamps_invalid_second_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** unknown" "$selected_timestamps_invalid_second_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-second-no-rows-scope summary to suppress invalid-second timestamp literals." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$selected_timestamps_invalid_second_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-second-no-rows-scope summary to render unknown duration for invalid-second timestamps." >&2
	exit 1
fi
if grep -Fq "20260215T110060Z" "$selected_timestamps_invalid_second_no_rows_scope_step_summary" || grep -Fq "20260215T110065Z" "$selected_timestamps_invalid_second_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-second-no-rows-scope summary to ignore invalid-second timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_invalid_second_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-invalid-second-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_invalid_hour_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-hour-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$selected_timestamps_invalid_hour_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** unknown" "$selected_timestamps_invalid_hour_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-hour-no-rows-scope summary to suppress invalid-hour timestamp literals." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$selected_timestamps_invalid_hour_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-hour-no-rows-scope summary to render unknown duration for invalid-hour timestamps." >&2
	exit 1
fi
if grep -Fq "20260215T240000Z" "$selected_timestamps_invalid_hour_no_rows_scope_step_summary" || grep -Fq "20260215T240005Z" "$selected_timestamps_invalid_hour_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-hour-no-rows-scope summary to ignore invalid-hour timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_invalid_hour_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-invalid-hour-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_invalid_minute_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-minute-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$selected_timestamps_invalid_minute_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** unknown" "$selected_timestamps_invalid_minute_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-minute-no-rows-scope summary to suppress invalid-minute timestamp literals." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$selected_timestamps_invalid_minute_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-minute-no-rows-scope summary to render unknown duration for invalid-minute timestamps." >&2
	exit 1
fi
if grep -Fq "20260215T116000Z" "$selected_timestamps_invalid_minute_no_rows_scope_step_summary" || grep -Fq "20260215T116005Z" "$selected_timestamps_invalid_minute_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-invalid-minute-no-rows-scope summary to ignore invalid-minute timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_invalid_minute_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-invalid-minute-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_year_boundary_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-year-boundary-valid-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20261231T235959Z" "$selected_timestamps_year_boundary_valid_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20270101T000004Z" "$selected_timestamps_year_boundary_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-year-boundary-valid-no-rows-scope summary to preserve valid year-boundary timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 5s" "$selected_timestamps_year_boundary_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-year-boundary-valid-no-rows-scope summary to derive duration across year boundaries." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_year_boundary_valid_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-year-boundary-valid-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_day_boundary_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-day-boundary-valid-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260228T235959Z" "$selected_timestamps_day_boundary_valid_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20260301T000004Z" "$selected_timestamps_day_boundary_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-day-boundary-valid-no-rows-scope summary to preserve valid day-boundary timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 5s" "$selected_timestamps_day_boundary_valid_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-day-boundary-valid-no-rows-scope summary to derive duration across day boundaries." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_day_boundary_valid_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-day-boundary-valid-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_whitespace_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-whitespace-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T111500Z" "$selected_timestamps_whitespace_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20260215T111505Z" "$selected_timestamps_whitespace_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-whitespace-no-rows-scope summary to trim padded timestamp literals before rendering." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 5s" "$selected_timestamps_whitespace_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-whitespace-no-rows-scope summary to derive duration from trimmed timestamp literals." >&2
	exit 1
fi
if grep -Fq " 20260215T111500Z " "$selected_timestamps_whitespace_no_rows_scope_step_summary" || grep -Fq $'\t20260215T111505Z\t' "$selected_timestamps_whitespace_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-whitespace-no-rows-scope summary to suppress raw padded timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_whitespace_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-whitespace-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_conflicting_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-conflicting-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T130010Z" "$selected_timestamps_conflicting_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20260215T130000Z" "$selected_timestamps_conflicting_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-conflicting-no-rows-scope summary to preserve conflicting explicit timestamps for diagnostics." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$selected_timestamps_conflicting_no_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-conflicting-no-rows-scope summary to avoid negative durations and render unknown." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_conflicting_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-conflicting-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** missing-only" "$selected_timestamps_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T120000Z" "$selected_timestamps_unmatched_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20260215T120005Z" "$selected_timestamps_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-scope summary to preserve explicit timestamps when selected scope has no matched rows." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 5s" "$selected_timestamps_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-scope summary to derive total duration from explicit timestamps when selected scope has no matched rows." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass |' "$selected_timestamps_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-scope summary to retain unmatched-selection table fallback rows." >&2
	exit 1
fi
if grep -Fq "20260215T140000Z" "$selected_timestamps_unmatched_rows_scope_step_summary" || grep -Fq "20260215T140001Z" "$selected_timestamps_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-scope summary to ignore non-selected row timestamps in selected-scope timestamp metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_unmatched_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-unmatched-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** missing-only" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-malformed-explicit-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary" || ! grep -Fq "**Completed:** unknown" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-malformed-explicit-scope summary to suppress malformed explicit timestamps when selected scope has no matched rows." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-malformed-explicit-scope summary to keep total duration unknown when selected-scope timing evidence is unresolved." >&2
	exit 1
fi
if grep -Fq "20260230T120000Z" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary" || grep -Fq "20260230T120005Z" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-malformed-explicit-scope summary to suppress malformed explicit timestamp literals." >&2
	exit 1
fi
if grep -Fq "20260215T140000Z" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary" || grep -Fq "20260215T140001Z" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-unmatched-rows-malformed-explicit-scope summary to keep selected-scope started/completed metadata independent from fallback table rows." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_unmatched_rows_malformed_explicit_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-unmatched-rows-malformed-explicit-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_timestamps_malformed_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-scope summary to preserve selected-gate ordering." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T100000Z" "$selected_timestamps_malformed_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20260215T100004Z" "$selected_timestamps_malformed_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-scope summary to derive timestamps from canonical selected row timestamps only." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 4s" "$selected_timestamps_malformed_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-scope summary to derive duration from canonical selected row timestamps." >&2
	exit 1
fi
if grep -Fq "20260001T000000Z" "$selected_timestamps_malformed_rows_scope_step_summary" || grep -Fq "20260001T000003Z" "$selected_timestamps_malformed_rows_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-scope summary to suppress malformed row timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_malformed_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-malformed-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_timestamps_malformed_rows_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-explicit-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$selected_timestamps_malformed_rows_explicit_scope_step_summary" || ! grep -Fq "**Completed:** unknown" "$selected_timestamps_malformed_rows_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-explicit-scope summary to suppress explicit timestamps when selected rows exist but row timestamps are malformed." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 3s" "$selected_timestamps_malformed_rows_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-explicit-scope summary to derive total duration from selected row duration evidence when row timestamps are malformed." >&2
	exit 1
fi
if grep -Fq "20260215T160000Z" "$selected_timestamps_malformed_rows_explicit_scope_step_summary" || grep -Fq "20260215T160005Z" "$selected_timestamps_malformed_rows_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-explicit-scope summary to ignore explicit selected-scope start/completion timestamps when selected rows are present." >&2
	exit 1
fi
if grep -Fq "20260230T160000Z" "$selected_timestamps_malformed_rows_explicit_scope_step_summary" || grep -Fq "20260230T160003Z" "$selected_timestamps_malformed_rows_explicit_scope_step_summary"; then
	echo "Expected selected-timestamps-malformed-rows-explicit-scope summary to suppress malformed selected row timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_timestamps_malformed_rows_explicit_scope_step_summary"; then
	echo "Did not expect schema warning for selected-timestamps-malformed-rows-explicit-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_duration_zero_map_no_rows_scope_step_summary"; then
	echo "Expected selected-duration-zero-map-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Gate duration map (s):** {\"lint\":0}" "$selected_duration_zero_map_no_rows_scope_step_summary"; then
	echo "Expected selected-duration-zero-map-no-rows-scope summary to preserve explicit zero-valued selected duration-map evidence." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 0s" "$selected_duration_zero_map_no_rows_scope_step_summary"; then
	echo "Expected selected-duration-zero-map-no-rows-scope summary to preserve deterministic zero total duration when explicit duration evidence exists." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$selected_duration_zero_map_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** unknown" "$selected_duration_zero_map_no_rows_scope_step_summary"; then
	echo "Expected selected-duration-zero-map-no-rows-scope summary to keep timestamps unknown when only explicit zero-duration map evidence exists." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_duration_zero_map_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-duration-zero-map-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$timestamps_malformed_explicit_unscoped_step_summary"; then
	echo "Expected timestamps-malformed-explicit-unscoped summary to derive selected-gate metadata from normalized rows." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T170000Z" "$timestamps_malformed_explicit_unscoped_step_summary" || ! grep -Fq "**Completed:** 20260215T170002Z" "$timestamps_malformed_explicit_unscoped_step_summary"; then
	echo "Expected timestamps-malformed-explicit-unscoped summary to ignore malformed explicit timestamps and derive from canonical row timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 2s" "$timestamps_malformed_explicit_unscoped_step_summary"; then
	echo "Expected timestamps-malformed-explicit-unscoped summary to derive total duration from canonical row timestamps." >&2
	exit 1
fi
if grep -Fq "20260230T170000Z" "$timestamps_malformed_explicit_unscoped_step_summary" || grep -Fq "20260230T170005Z" "$timestamps_malformed_explicit_unscoped_step_summary"; then
	echo "Expected timestamps-malformed-explicit-unscoped summary to suppress malformed explicit timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$timestamps_malformed_explicit_unscoped_step_summary"; then
	echo "Did not expect schema warning for timestamps-malformed-explicit-unscoped summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** none" "$timestamps_invalid_explicit_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-invalid-explicit-no-rows-unscoped summary to keep selected-gate metadata empty." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$timestamps_invalid_explicit_no_rows_unscoped_step_summary" || ! grep -Fq "**Completed:** unknown" "$timestamps_invalid_explicit_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-invalid-explicit-no-rows-unscoped summary to suppress malformed explicit timestamps without row fallbacks." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$timestamps_invalid_explicit_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-invalid-explicit-no-rows-unscoped summary to keep total duration unknown when malformed explicit timestamps are unresolved." >&2
	exit 1
fi
if grep -Fq "20260230T180000Z" "$timestamps_invalid_explicit_no_rows_unscoped_step_summary" || grep -Fq "20260230T180005Z" "$timestamps_invalid_explicit_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-invalid-explicit-no-rows-unscoped summary to suppress malformed explicit timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$timestamps_invalid_explicit_no_rows_unscoped_step_summary"; then
	echo "Did not expect schema warning for timestamps-invalid-explicit-no-rows-unscoped summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** none" "$timestamps_whitespace_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-whitespace-no-rows-unscoped summary to keep selected-gate metadata empty." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T181500Z" "$timestamps_whitespace_no_rows_unscoped_step_summary" || ! grep -Fq "**Completed:** 20260215T181505Z" "$timestamps_whitespace_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-whitespace-no-rows-unscoped summary to trim padded explicit timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 5s" "$timestamps_whitespace_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-whitespace-no-rows-unscoped summary to derive duration from trimmed explicit timestamps." >&2
	exit 1
fi
if grep -Fq " 20260215T181500Z " "$timestamps_whitespace_no_rows_unscoped_step_summary" || grep -Fq $'\t20260215T181505Z\t' "$timestamps_whitespace_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-whitespace-no-rows-unscoped summary to suppress raw padded explicit timestamp literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$timestamps_whitespace_no_rows_unscoped_step_summary"; then
	echo "Did not expect schema warning for timestamps-whitespace-no-rows-unscoped summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** none" "$timestamps_conflicting_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-conflicting-no-rows-unscoped summary to keep selected-gate metadata empty." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T190010Z" "$timestamps_conflicting_no_rows_unscoped_step_summary" || ! grep -Fq "**Completed:** 20260215T190000Z" "$timestamps_conflicting_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-conflicting-no-rows-unscoped summary to preserve conflicting explicit timestamps for diagnostics." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$timestamps_conflicting_no_rows_unscoped_step_summary"; then
	echo "Expected timestamps-conflicting-no-rows-unscoped summary to render unknown duration for reversed unscoped timestamps." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$timestamps_conflicting_no_rows_unscoped_step_summary"; then
	echo "Did not expect schema warning for timestamps-conflicting-no-rows-unscoped summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** none" "$timestamps_conflicting_no_rows_with_explicit_total_unscoped_step_summary"; then
	echo "Expected timestamps-conflicting-no-rows-with-explicit-total-unscoped summary to keep selected-gate metadata empty." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T190010Z" "$timestamps_conflicting_no_rows_with_explicit_total_unscoped_step_summary" || ! grep -Fq "**Completed:** 20260215T190000Z" "$timestamps_conflicting_no_rows_with_explicit_total_unscoped_step_summary"; then
	echo "Expected timestamps-conflicting-no-rows-with-explicit-total-unscoped summary to preserve conflicting explicit timestamps for diagnostics." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 9s" "$timestamps_conflicting_no_rows_with_explicit_total_unscoped_step_summary"; then
	echo "Expected timestamps-conflicting-no-rows-with-explicit-total-unscoped summary to preserve explicit total duration despite reversed timestamps." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$timestamps_conflicting_no_rows_with_explicit_total_unscoped_step_summary"; then
	echo "Did not expect schema warning for timestamps-conflicting-no-rows-with-explicit-total-unscoped summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** none" "$total_duration_conflict_duration_map_no_rows_unscoped_step_summary"; then
	echo "Expected total-duration-conflict-duration-map-no-rows-unscoped summary to keep selected-gate metadata empty when only unscoped duration-map evidence is present." >&2
	exit 1
fi
if ! grep -Fq '**Gate duration map (s):** {"lint":3}' "$total_duration_conflict_duration_map_no_rows_unscoped_step_summary"; then
	echo "Expected total-duration-conflict-duration-map-no-rows-unscoped summary to preserve unscoped duration-map evidence." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 7s" "$total_duration_conflict_duration_map_no_rows_unscoped_step_summary"; then
	echo "Expected total-duration-conflict-duration-map-no-rows-unscoped summary to preserve explicit unscoped total duration over duration-map fallback." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$total_duration_conflict_duration_map_no_rows_unscoped_step_summary"; then
	echo "Did not expect schema warning for total-duration-conflict-duration-map-no-rows-unscoped summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_total_duration_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 7s" "$selected_total_duration_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-no-rows-scope summary to preserve explicit total duration when selected scope has no rows/timestamps." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_total_duration_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-total-duration-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_total_duration_conflict_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflict-duration-map-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq '**Gate duration map (s):** {"lint":3}' "$selected_total_duration_conflict_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflict-duration-map-no-rows-scope summary to preserve selected duration-map evidence." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 3s" "$selected_total_duration_conflict_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflict-duration-map-no-rows-scope summary to prioritize selected duration-map evidence over conflicting explicit totalDurationSeconds." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_total_duration_conflict_duration_map_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-total-duration-conflict-duration-map-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_total_duration_conflict_zero_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflict-zero-duration-map-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq '**Gate duration map (s):** {"lint":0}' "$selected_total_duration_conflict_zero_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflict-zero-duration-map-no-rows-scope summary to preserve selected zero-duration-map evidence." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 0s" "$selected_total_duration_conflict_zero_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflict-zero-duration-map-no-rows-scope summary to prioritize selected zero-duration-map evidence over conflicting explicit totalDurationSeconds." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_total_duration_conflict_zero_duration_map_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-total-duration-conflict-zero-duration-map-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_total_duration_nonselected_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-nonselected-duration-map-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq '**Gate duration map (s):** {"lint":0}' "$selected_total_duration_nonselected_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-nonselected-duration-map-no-rows-scope summary to scope non-selected duration-map entries out of selected map metadata." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 7s" "$selected_total_duration_nonselected_duration_map_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-nonselected-duration-map-no-rows-scope summary to preserve explicit selected total duration when duration-map evidence is only non-selected." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_total_duration_nonselected_duration_map_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-total-duration-nonselected-duration-map-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-nonselected-duration-map-without-explicit-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq '**Gate duration map (s):** {"lint":0}' "$selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-nonselected-duration-map-without-explicit-no-rows-scope summary to scope non-selected duration-map entries out of selected map metadata." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** unknown" "$selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-nonselected-duration-map-without-explicit-no-rows-scope summary to keep total duration unknown when selected duration evidence is absent and no explicit total duration is provided." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_total_duration_nonselected_duration_map_without_explicit_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-total-duration-nonselected-duration-map-without-explicit-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_total_duration_conflicting_timestamps_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflicting-timestamps-no-rows-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T190010Z" "$selected_total_duration_conflicting_timestamps_no_rows_scope_step_summary" || ! grep -Fq "**Completed:** 20260215T190000Z" "$selected_total_duration_conflicting_timestamps_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflicting-timestamps-no-rows-scope summary to preserve conflicting selected-scope timestamps for diagnostics." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 9s" "$selected_total_duration_conflicting_timestamps_no_rows_scope_step_summary"; then
	echo "Expected selected-total-duration-conflicting-timestamps-no-rows-scope summary to preserve explicit selected total-duration scalar when selected rows are absent." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_total_duration_conflicting_timestamps_no_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-total-duration-conflicting-timestamps-no-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scope_step_summary"; then
	echo "Expected selected-run-state-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$selected_run_state_scope_step_summary" || ! grep -Fq "**Exit reason:** success" "$selected_run_state_scope_step_summary" || ! grep -Fq "**Run classification:** success-no-retries" "$selected_run_state_scope_step_summary"; then
	echo "Expected selected-run-state-scope summary to ignore conflicting explicit run-state scalars when selected-scope outcome evidence exists." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$selected_run_state_scope_step_summary" || ! grep -Fq "**Continue on failure:** false" "$selected_run_state_scope_step_summary"; then
	echo "Expected selected-run-state-scope summary to derive dry-run/continue-on-failure from selected-scope outcome evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_no_evidence_scope_step_summary"; then
	echo "Expected selected-run-state-no-evidence-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_no_evidence_scope_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$selected_run_state_no_evidence_scope_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$selected_run_state_no_evidence_scope_step_summary"; then
	echo "Expected selected-run-state-no-evidence-scope summary to preserve explicit run-state scalars when selected-scope outcome evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$selected_run_state_no_evidence_scope_step_summary" || ! grep -Fq "**Continue on failure:** true" "$selected_run_state_no_evidence_scope_step_summary"; then
	echo "Expected selected-run-state-no-evidence-scope summary to preserve explicit dry-run/continue-on-failure when selected-scope outcome evidence is absent." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_no_evidence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-no-evidence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-run-state-nonselected-evidence-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_nonselected_evidence_scope_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$selected_run_state_nonselected_evidence_scope_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$selected_run_state_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-run-state-nonselected-evidence-scope summary to preserve explicit run-state when only non-selected scoped-out map evidence exists." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$selected_run_state_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-run-state-nonselected-evidence-scope summary to preserve explicit continue-on-failure when selected-scope outcome evidence is empty after scoping." >&2
	exit 1
fi
if grep -Fq "build" "$selected_run_state_nonselected_evidence_scope_step_summary"; then
	echo "Expected selected-run-state-nonselected-evidence-scope summary to exclude non-selected map evidence from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_nonselected_evidence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-nonselected-evidence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_unknown_status_scope_step_summary"; then
	echo "Expected selected-run-state-unknown-status-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_unknown_status_scope_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$selected_run_state_unknown_status_scope_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$selected_run_state_unknown_status_scope_step_summary"; then
	echo "Expected selected-run-state-unknown-status-scope summary to preserve explicit failure run-state when selected-scope statuses are unresolved." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$selected_run_state_unknown_status_scope_step_summary"; then
	echo "Expected selected-run-state-unknown-status-scope summary to preserve explicit continue-on-failure when selected-scope statuses are unresolved." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | unknown |' "$selected_run_state_unknown_status_scope_step_summary"; then
	echo "Expected selected-run-state-unknown-status-scope summary to render unresolved selected row status as unknown." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_unknown_status_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-unknown-status-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_run_state_partial_status_scope_step_summary"; then
	echo "Expected selected-run-state-partial-status-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_partial_status_scope_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$selected_run_state_partial_status_scope_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$selected_run_state_partial_status_scope_step_summary"; then
	echo "Expected selected-run-state-partial-status-scope summary to preserve explicit run-state when selected status coverage is partial." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$selected_run_state_partial_status_scope_step_summary"; then
	echo "Expected selected-run-state-partial-status-scope summary to preserve explicit continue-on-failure when selected status coverage is partial." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {"lint":"pass"}' "$selected_run_state_partial_status_scope_step_summary"; then
	echo "Expected selected-run-state-partial-status-scope summary to keep scoped status-map entries without synthesizing missing selected statuses in map output." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_partial_status_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-partial-status-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_failure_scope_step_summary"; then
	echo "Expected selected-run-state-failure-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_failure_scope_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$selected_run_state_failure_scope_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$selected_run_state_failure_scope_step_summary"; then
	echo "Expected selected-run-state-failure-scope summary to ignore conflicting explicit success run-state when selected-scope failure evidence exists." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$selected_run_state_failure_scope_step_summary" || ! grep -Fq "**Failed gate:** lint" "$selected_run_state_failure_scope_step_summary" || ! grep -Fq "**Failed gate exit code:** 7" "$selected_run_state_failure_scope_step_summary"; then
	echo "Expected selected-run-state-failure-scope summary to preserve selected failure metadata and derived fail-fast/continued semantics." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_failure_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-failure-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_not_run_scope_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$selected_run_state_not_run_scope_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$selected_run_state_not_run_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-scope summary to preserve explicit failure run-state when selected-scope evidence is non-executed only." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$selected_run_state_not_run_scope_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$selected_run_state_not_run_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-scope summary to preserve explicit continue-on-failure alongside selected not-run evidence." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | not-run |' "$selected_run_state_not_run_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-scope summary to render selected not-run row." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_selected_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_not_run_blocked_selected_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_not_run_blocked_selected_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_not_run_blocked_selected_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-scope summary to override conflicting explicit success state with selected blocked-by-fail-fast evidence." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_not_run_blocked_selected_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-scope summary to derive blocked-by gate from selected not-run reason." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_selected_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-selected-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_selected_whitespace_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-whitespace-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_not_run_blocked_selected_whitespace_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_not_run_blocked_selected_whitespace_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_not_run_blocked_selected_whitespace_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-whitespace-scope summary to normalize whitespace around blocked-by-fail-fast reason gate IDs." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_not_run_blocked_selected_whitespace_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-whitespace-scope summary to trim blocked-by-fail-fast reason gate IDs before selected-scope matching." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_selected_whitespace_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-selected-whitespace-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_selected_uppercase_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-uppercase-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_not_run_blocked_selected_uppercase_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_not_run_blocked_selected_uppercase_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_not_run_blocked_selected_uppercase_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-uppercase-scope summary to parse blocked-by-fail-fast reasons case-insensitively." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_not_run_blocked_selected_uppercase_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-uppercase-scope summary to normalize uppercase blocked-by-fail-fast reasons to selected gate IDs." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_selected_uppercase_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-selected-uppercase-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_selected_spaced_colon_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-spaced-colon-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_not_run_blocked_selected_spaced_colon_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_not_run_blocked_selected_spaced_colon_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_not_run_blocked_selected_spaced_colon_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-spaced-colon-scope summary to parse blocked-by-fail-fast prefixes with optional whitespace before colon." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_not_run_blocked_selected_spaced_colon_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-spaced-colon-scope summary to resolve blocked gate ID when blocked-by prefix contains whitespace before colon." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_selected_spaced_colon_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-selected-spaced-colon-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_empty_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-empty-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$selected_run_state_not_run_blocked_empty_scope_step_summary" || ! grep -Fq "**Exit reason:** success" "$selected_run_state_not_run_blocked_empty_scope_step_summary" || ! grep -Fq "**Run classification:** success-no-retries" "$selected_run_state_not_run_blocked_empty_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-empty-scope summary to ignore blocked-by-fail-fast reasons with blank gate IDs." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$selected_run_state_not_run_blocked_empty_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-empty-scope summary to suppress blank blocked-by-fail-fast reason IDs." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_empty_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-empty-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_none_sentinel_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-none-sentinel-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$selected_run_state_not_run_blocked_none_sentinel_scope_step_summary" || ! grep -Fq "**Exit reason:** success" "$selected_run_state_not_run_blocked_none_sentinel_scope_step_summary" || ! grep -Fq "**Run classification:** success-no-retries" "$selected_run_state_not_run_blocked_none_sentinel_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-none-sentinel-scope summary to ignore blocked-by-fail-fast reasons targeting scalar 'none' sentinel IDs." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$selected_run_state_not_run_blocked_none_sentinel_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-none-sentinel-scope summary to suppress blocked-by-fail-fast sentinel gate IDs." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_none_sentinel_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-none-sentinel-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_selected_continue_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-continue-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_not_run_blocked_selected_continue_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_not_run_blocked_selected_continue_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_not_run_blocked_selected_continue_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-continue-scope summary to preserve fail-fast override under selected blocked reason evidence." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$selected_run_state_not_run_blocked_selected_continue_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-continue-scope summary to ignore conflicting continue-on-failure=true under selected blocked reason fail-fast evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_selected_continue_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-selected-continue-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_selected_dry_reason_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-dry-reason-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_not_run_blocked_selected_dry_reason_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_not_run_blocked_selected_dry_reason_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_not_run_blocked_selected_dry_reason_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-dry-reason-scope summary to ignore conflicting dry-run reason/classification under selected blocked-reason fail-fast evidence." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$selected_run_state_not_run_blocked_selected_dry_reason_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-dry-reason-scope summary to clear dry-run metadata under selected blocked-reason fail-fast evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_selected_dry_reason_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-selected-dry-reason-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_selected_continued_conflict_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-continued-conflict-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_not_run_blocked_selected_continued_conflict_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_not_run_blocked_selected_continued_conflict_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_not_run_blocked_selected_continued_conflict_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-continued-conflict-scope summary to ignore conflicting continued-failure metadata under selected blocked-reason fail-fast evidence." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$selected_run_state_not_run_blocked_selected_continued_conflict_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-selected-continued-conflict-scope summary to ignore continue-on-failure=true under selected blocked-reason fail-fast evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_selected_continued_conflict_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-selected-continued-conflict-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_not_run_blocked_nonselected_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-nonselected-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$selected_run_state_not_run_blocked_nonselected_scope_step_summary" || ! grep -Fq "**Exit reason:** success" "$selected_run_state_not_run_blocked_nonselected_scope_step_summary" || ! grep -Fq "**Run classification:** success-no-retries" "$selected_run_state_not_run_blocked_nonselected_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-nonselected-scope summary to ignore non-selected blocked-by not-run reasons for run-state derivation." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$selected_run_state_not_run_blocked_nonselected_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-nonselected-scope summary to suppress non-selected blocked-by not-run reasons." >&2
	exit 1
fi
if grep -Fq "**Blocked by gate:** build" "$selected_run_state_not_run_blocked_nonselected_scope_step_summary"; then
	echo "Expected selected-run-state-not-run-blocked-nonselected-scope summary to exclude non-selected blocked-by reason gate IDs from blocked-by metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_not_run_blocked_nonselected_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-not-run-blocked-nonselected-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scalar_failure_only_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-failure-only-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_scalar_failure_only_scope_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$selected_run_state_scalar_failure_only_scope_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$selected_run_state_scalar_failure_only_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-failure-only-scope summary to treat selected scalar failed-gate metadata as failure outcome evidence overriding conflicting explicit success state." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** lint" "$selected_run_state_scalar_failure_only_scope_step_summary" || ! grep -Fq "**Failed gate exit code:** 7" "$selected_run_state_scalar_failure_only_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-failure-only-scope summary to preserve selected scalar failed-gate metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scalar_failure_only_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scalar-failure-only-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scalar_blocked_only_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-only-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_scalar_blocked_only_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_scalar_blocked_only_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_scalar_blocked_only_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-only-scope summary to treat selected scalar blocked-by metadata as fail-fast evidence overriding conflicting explicit success state." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_scalar_blocked_only_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-only-scope summary to preserve selected scalar blocked-by metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scalar_blocked_only_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scalar-blocked-only-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scalar_blocked_whitespace_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-whitespace-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_scalar_blocked_whitespace_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_scalar_blocked_whitespace_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_scalar_blocked_whitespace_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-whitespace-scope summary to normalize whitespace around scalar blockedByGateId before selected-scope fail-fast derivation." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_scalar_blocked_whitespace_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-whitespace-scope summary to trim scalar blockedByGateId values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scalar_blocked_whitespace_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scalar-blocked-whitespace-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scalar_blocked_empty_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-empty-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$selected_run_state_scalar_blocked_empty_scope_step_summary" || ! grep -Fq "**Exit reason:** success" "$selected_run_state_scalar_blocked_empty_scope_step_summary" || ! grep -Fq "**Run classification:** success-no-retries" "$selected_run_state_scalar_blocked_empty_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-empty-scope summary to ignore blank scalar blockedByGateId values." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$selected_run_state_scalar_blocked_empty_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-empty-scope summary to suppress blank scalar blockedByGateId values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scalar_blocked_empty_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scalar-blocked-empty-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scalar_blocked_continue_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-continue-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_scalar_blocked_continue_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_scalar_blocked_continue_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_scalar_blocked_continue_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-continue-scope summary to preserve fail-fast override under selected blocked-by scalar evidence." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$selected_run_state_scalar_blocked_continue_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-continue-scope summary to ignore conflicting continue-on-failure=true when selected fail-fast evidence exists." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scalar_blocked_continue_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scalar-blocked-continue-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scalar_blocked_dry_run_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-dry-run-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_scalar_blocked_dry_run_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_scalar_blocked_dry_run_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_scalar_blocked_dry_run_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-dry-run-scope summary to ignore conflicting dry-run=true under selected fail-fast evidence." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$selected_run_state_scalar_blocked_dry_run_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-dry-run-scope summary to clear dry-run metadata when selected fail-fast evidence exists." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scalar_blocked_dry_run_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scalar-blocked-dry-run-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scalar_blocked_dry_reason_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-dry-reason-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_scalar_blocked_dry_reason_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_scalar_blocked_dry_reason_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_scalar_blocked_dry_reason_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-dry-reason-scope summary to ignore conflicting exitReason/runClassification dry-run under selected fail-fast evidence." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$selected_run_state_scalar_blocked_dry_reason_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-dry-reason-scope summary to clear dry-run metadata when selected fail-fast evidence exists." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scalar_blocked_dry_reason_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scalar-blocked-dry-reason-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_scalar_blocked_continued_conflict_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-continued-conflict-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_scalar_blocked_continued_conflict_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_scalar_blocked_continued_conflict_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_scalar_blocked_continued_conflict_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-continued-conflict-scope summary to ignore conflicting completed-with-failures/failed-continued run-state under selected fail-fast evidence." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$selected_run_state_scalar_blocked_continued_conflict_scope_step_summary"; then
	echo "Expected selected-run-state-scalar-blocked-continued-conflict-scope summary to ignore continue-on-failure=true under selected fail-fast evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_scalar_blocked_continued_conflict_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-scalar-blocked-continued-conflict-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_nonselected_blocked_scope_step_summary"; then
	echo "Expected selected-run-state-nonselected-blocked-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$selected_run_state_nonselected_blocked_scope_step_summary" || ! grep -Fq "**Exit reason:** success" "$selected_run_state_nonselected_blocked_scope_step_summary" || ! grep -Fq "**Run classification:** success-no-retries" "$selected_run_state_nonselected_blocked_scope_step_summary"; then
	echo "Expected selected-run-state-nonselected-blocked-scope summary to ignore non-selected blocked-by scalar metadata in selected-scope run-state derivation." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$selected_run_state_nonselected_blocked_scope_step_summary"; then
	echo "Expected selected-run-state-nonselected-blocked-scope summary to suppress non-selected blocked-by scalar metadata." >&2
	exit 1
fi
if grep -Fq "build" "$selected_run_state_nonselected_blocked_scope_step_summary"; then
	echo "Expected selected-run-state-nonselected-blocked-scope summary to exclude non-selected blocked-by gate IDs from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_nonselected_blocked_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-nonselected-blocked-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_blocked_reason_pass_status_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-pass-status-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$selected_run_state_blocked_reason_pass_status_scope_step_summary" || ! grep -Fq "**Exit reason:** success" "$selected_run_state_blocked_reason_pass_status_scope_step_summary" || ! grep -Fq "**Run classification:** success-no-retries" "$selected_run_state_blocked_reason_pass_status_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-pass-status-scope summary to prioritize selected pass status over conflicting not-run list/reason values." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$selected_run_state_blocked_reason_pass_status_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-pass-status-scope summary to suppress blocked-by metadata when reason-bearing gate status is not-run-ineligible." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_blocked_reason_pass_status_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-blocked-reason-pass-status-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** typecheck, lint" "$selected_run_state_blocked_scalar_precedence_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-scalar-precedence-scope summary to preserve selected gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_blocked_scalar_precedence_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-scalar-precedence-scope summary to prioritize explicit blockedByGateId over row-derived blocked reason precedence." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_blocked_scalar_precedence_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_blocked_scalar_precedence_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-scalar-precedence-scope summary to retain fail-fast semantics under blocked scalar precedence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_blocked_scalar_precedence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-blocked-scalar-precedence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_blocked_reason_not_run_list_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-not-run-list-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_blocked_reason_not_run_list_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_blocked_reason_not_run_list_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_blocked_reason_not_run_list_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-not-run-list-scope summary to use selected not-run list evidence with blocked reason for fail-fast derivation even when status map omits the gate." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_blocked_reason_not_run_list_scope_step_summary" || ! grep -Fq "**Not-run gates list:** lint" "$selected_run_state_blocked_reason_not_run_list_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-not-run-list-scope summary to preserve blocked-by and not-run list metadata under sparse status-map coverage." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_blocked_reason_not_run_list_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-blocked-reason-not-run-list-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-unknown-status-not-run-list-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-unknown-status-not-run-list-scope summary to treat selected unknown-status placeholders as defer-to-not-run-list for blocked-reason fail-fast derivation." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-unknown-status-not-run-list-scope summary to preserve blocked-by metadata from selected not-run list when status map is unknown placeholder." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_blocked_reason_unknown_status_not_run_list_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-blocked-reason-unknown-status-not-run-list-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** typecheck, lint" "$selected_run_state_blocked_reason_selected_order_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-selected-order-scope summary to preserve selected gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** typecheck" "$selected_run_state_blocked_reason_selected_order_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-selected-order-scope summary to prioritize blocked-by derivation using selected gate order when multiple blocked reasons are present." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$selected_run_state_blocked_reason_selected_order_scope_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$selected_run_state_blocked_reason_selected_order_scope_step_summary"; then
	echo "Expected selected-run-state-blocked-reason-selected-order-scope summary to retain fail-fast run-state semantics under selected-order blocked reason precedence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_blocked_reason_selected_order_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-blocked-reason-selected-order-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_non_success_partition_fallback_scope_step_summary"; then
	echo "Expected selected-non-success-partition-fallback-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Not-run gates list:** lint" "$selected_non_success_partition_fallback_scope_step_summary"; then
	echo "Expected selected-non-success-partition-fallback-scope summary to preserve selected not-run partition metadata." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint" "$selected_non_success_partition_fallback_scope_step_summary" || ! grep -Fq "**Attention gates list:** lint" "$selected_non_success_partition_fallback_scope_step_summary"; then
	echo "Expected selected-non-success-partition-fallback-scope summary to derive non-success/attention lists from selected partition evidence when status map entries are missing." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_non_success_partition_fallback_scope_step_summary"; then
	echo "Did not expect schema warning for selected-non-success-partition-fallback-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_non_success_status_precedence_scope_step_summary"; then
	echo "Expected selected-non-success-status-precedence-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_non_success_status_precedence_scope_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$selected_non_success_status_precedence_scope_step_summary"; then
	echo "Expected selected-non-success-status-precedence-scope summary to surface conflicting pass/not-run aggregate metadata for diagnostic visibility." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** none" "$selected_non_success_status_precedence_scope_step_summary" || ! grep -Fq "**Attention gates list:** none" "$selected_non_success_status_precedence_scope_step_summary"; then
	echo "Expected selected-non-success-status-precedence-scope summary to prioritize selected status-map pass evidence over fallback not-run partition membership for non-success/attention derivation." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_non_success_status_precedence_scope_step_summary"; then
	echo "Did not expect schema warning for selected-non-success-status-precedence-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-partition-lists-status-map-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 0" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary" || ! grep -Fq "**Failed gates:** 0" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-partition-lists-status-map-scope summary to keep explicit empty selected partition lists authoritative for partition counts." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":0,"fail":0,"skip":0,"not-run":0}' "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-partition-lists-status-map-scope summary to keep status counts aligned with explicit empty selected partition lists." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {"lint":"pass","typecheck":"fail"}' "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-partition-lists-status-map-scope summary to preserve selected status-map metadata when partition lists are explicitly empty." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary" || ! grep -Fq "**Executed gates list:** lint, typecheck" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-partition-lists-status-map-scope summary to derive selected executed metadata from selected status-map evidence even when partition lists are explicitly empty." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** none" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary" || ! grep -Fq "**Failed gates list:** none" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary" || ! grep -Fq "**Not-run gates list:** none" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-partition-lists-status-map-scope summary to preserve explicit empty selected partition list labels." >&2
	exit 1
fi
if ! grep -Fq "**Pass rate (executed gates):** 0%" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary" || ! grep -Fq "**Retry rate (executed gates):** 0%" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-partition-lists-status-map-scope summary to derive selected executed-rate metrics from explicit empty partition counts plus selected executed fallback." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary" || ! grep -Fq "**Attention gates list:** typecheck" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-partition-lists-status-map-scope summary to derive non-success/attention lists from selected status-map evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_empty_partition_lists_status_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-empty-partition-lists-status-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_executed_fallback_empty_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-empty-status-map-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_executed_fallback_empty_status_map_scope_step_summary" || ! grep -Fq "**Executed gates:** 1" "$selected_executed_fallback_empty_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-empty-status-map-scope summary to derive executed count from selected partition fallback when selected status-map entries are absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates list:** lint" "$selected_executed_fallback_empty_status_map_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$selected_executed_fallback_empty_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-empty-status-map-scope summary to derive executed list and pass rate from selected partition fallback." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {}' "$selected_executed_fallback_empty_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-empty-status-map-scope summary to preserve explicit empty selected status map metadata while deriving executed fallback from partitions." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_executed_fallback_empty_status_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-executed-fallback-empty-status-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_executed_explicit_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-explicit-empty-list-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_executed_explicit_empty_list_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_executed_explicit_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-explicit-empty-list-scope summary to preserve selected partition counts when explicit executed list is empty." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 0" "$selected_executed_explicit_empty_list_scope_step_summary" || ! grep -Fq "**Executed gates list:** none" "$selected_executed_explicit_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-explicit-empty-list-scope summary to keep explicit empty selected executed list authoritative." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_executed_explicit_empty_list_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_executed_explicit_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-explicit-empty-list-scope summary to render executed-rate metrics as n/a when explicit selected executed list is empty." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_executed_explicit_empty_list_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_executed_explicit_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-explicit-empty-list-scope summary to keep selected retried metadata scoped when executed list override is empty." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint, typecheck" "$selected_executed_explicit_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-explicit-empty-list-scope summary to preserve selected attention derivation from non-success + retried evidence despite empty executed list override." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_executed_explicit_empty_list_scope_step_summary"; then
	echo "Did not expect schema warning for selected-executed-explicit-empty-list-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_executed_scalar_count_ignored_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-scalar-count-ignored-empty-list-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 0" "$selected_executed_scalar_count_ignored_empty_list_scope_step_summary" || ! grep -Fq "**Executed gates list:** none" "$selected_executed_scalar_count_ignored_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-scalar-count-ignored-empty-list-scope summary to preserve explicit empty selected executed list metadata." >&2
	exit 1
fi
if ! grep -Fq "**Pass rate (executed gates):** n/a" "$selected_executed_scalar_count_ignored_empty_list_scope_step_summary" || ! grep -Fq "**Retry rate (executed gates):** n/a" "$selected_executed_scalar_count_ignored_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-scalar-count-ignored-empty-list-scope summary to render executed-rate metrics as n/a despite conflicting executedGateCount scalar under selected scope." >&2
	exit 1
fi
if grep -Fq "**Executed gates:** 5" "$selected_executed_scalar_count_ignored_empty_list_scope_step_summary" || grep -Fq "**Pass rate (executed gates):** 20%" "$selected_executed_scalar_count_ignored_empty_list_scope_step_summary"; then
	echo "Expected selected-executed-scalar-count-ignored-empty-list-scope summary to ignore conflicting executedGateCount scalar when selected scope is explicit." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_executed_scalar_count_ignored_empty_list_scope_step_summary"; then
	echo "Did not expect schema warning for selected-executed-scalar-count-ignored-empty-list-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_executed_fallback_partial_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-partial-status-map-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_executed_fallback_partial_status_map_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_executed_fallback_partial_status_map_scope_step_summary" || ! grep -Fq "**Executed gates:** 2" "$selected_executed_fallback_partial_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-partial-status-map-scope summary to derive executed counts from merged selected status-map and sparse partition fallback data." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates list:** lint, typecheck" "$selected_executed_fallback_partial_status_map_scope_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$selected_executed_fallback_partial_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-partial-status-map-scope summary to derive executed list/pass-rate from merged selected status-map and sparse partition fallback data." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck" "$selected_executed_fallback_partial_status_map_scope_step_summary" || ! grep -Fq "**Attention gates list:** typecheck" "$selected_executed_fallback_partial_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-partial-status-map-scope summary to align selected non-success metadata with merged status-map/partition evidence." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {"lint":"pass"}' "$selected_executed_fallback_partial_status_map_scope_step_summary"; then
	echo "Expected selected-executed-fallback-partial-status-map-scope summary to preserve explicit partial selected status-map metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_executed_fallback_partial_status_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-executed-fallback-partial-status-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_attention_retried_scope_step_summary"; then
	echo "Expected selected-attention-retried-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_attention_retried_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_attention_retried_scope_step_summary"; then
	echo "Expected selected-attention-retried-scope summary to scope retried metadata to selected IDs." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 2" "$selected_attention_retried_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 3s" "$selected_attention_retried_scope_step_summary"; then
	echo "Expected selected-attention-retried-scope summary to scope retry aggregates to selected retried IDs." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$selected_attention_retried_scope_step_summary"; then
	echo "Expected selected-attention-retried-scope summary to include selected retried pass gates in attention list." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** none" "$selected_attention_retried_scope_step_summary"; then
	echo "Expected selected-attention-retried-scope summary to keep non-success list clear when selected status is pass." >&2
	exit 1
fi
if grep -Fq "build" "$selected_attention_retried_scope_step_summary"; then
	echo "Expected selected-attention-retried-scope summary to exclude non-selected retried/status IDs from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_attention_retried_scope_step_summary"; then
	echo "Did not expect schema warning for selected-attention-retried-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_attention_retried_without_map_scope_step_summary"; then
	echo "Expected selected-attention-retried-without-map-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_attention_retried_without_map_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_attention_retried_without_map_scope_step_summary"; then
	echo "Expected selected-attention-retried-without-map-scope summary to scope retried metadata to selected IDs when retry map is omitted." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":1}" "$selected_attention_retried_without_map_scope_step_summary"; then
	echo "Expected selected-attention-retried-without-map-scope summary to synthesize scoped retry-count map from selected retried IDs." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 1" "$selected_attention_retried_without_map_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_attention_retried_without_map_scope_step_summary"; then
	echo "Expected selected-attention-retried-without-map-scope summary to derive retry aggregates from synthesized scoped retry-count map." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$selected_attention_retried_without_map_scope_step_summary"; then
	echo "Expected selected-attention-retried-without-map-scope summary to include selected retried pass gate in attention list." >&2
	exit 1
fi
if grep -Fq "build" "$selected_attention_retried_without_map_scope_step_summary"; then
	echo "Expected selected-attention-retried-without-map-scope summary to exclude non-selected retried/status IDs from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_attention_retried_without_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-attention-retried-without-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, build" "$explicit_retried_zero_count_retry_map_step_summary"; then
	echo "Expected explicit-retried-zero-count-retry-map summary to preserve derived gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$explicit_retried_zero_count_retry_map_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$explicit_retried_zero_count_retry_map_step_summary"; then
	echo "Expected explicit-retried-zero-count-retry-map summary to preserve explicit retried-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":1,\"build\":0}" "$explicit_retried_zero_count_retry_map_step_summary"; then
	echo "Expected explicit-retried-zero-count-retry-map summary to enforce minimum retry-count map values for explicit retried IDs while zeroing non-retried entries." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 1" "$explicit_retried_zero_count_retry_map_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$explicit_retried_zero_count_retry_map_step_summary"; then
	echo "Expected explicit-retried-zero-count-retry-map summary to keep retry aggregates aligned with explicit retried IDs." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$explicit_retried_zero_count_retry_map_step_summary"; then
	echo "Expected explicit-retried-zero-count-retry-map summary to include explicit retried IDs in attention fallback." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_retried_zero_count_retry_map_step_summary"; then
	echo "Did not expect schema warning for explicit-retried-zero-count-retry-map summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, build" "$explicit_retried_subset_retry_map_step_summary"; then
	echo "Expected explicit-retried-subset-retry-map summary to preserve derived gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$explicit_retried_subset_retry_map_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$explicit_retried_subset_retry_map_step_summary"; then
	echo "Expected explicit-retried-subset-retry-map summary to preserve explicit retried-gate subset metadata." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 3" "$explicit_retried_subset_retry_map_step_summary" || ! grep -Fq "**Total retry backoff:** 7s" "$explicit_retried_subset_retry_map_step_summary"; then
	echo "Expected explicit-retried-subset-retry-map summary to constrain retry aggregates to explicit retried-gate subset." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":3,\"build\":0}" "$explicit_retried_subset_retry_map_step_summary"; then
	echo "Expected explicit-retried-subset-retry-map summary to zero retry-count map entries outside explicit retried subset." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$explicit_retried_subset_retry_map_step_summary"; then
	echo "Expected explicit-retried-subset-retry-map summary to keep attention list constrained to explicit retried subset." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_retried_subset_retry_map_step_summary"; then
	echo "Did not expect schema warning for explicit-retried-subset-retry-map summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$explicit_retried_missing_retry_map_key_step_summary"; then
	echo "Expected explicit-retried-missing-retry-map-key summary to derive selected-gate metadata from explicit retried IDs when no rows/status maps are provided." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$explicit_retried_missing_retry_map_key_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$explicit_retried_missing_retry_map_key_step_summary"; then
	echo "Expected explicit-retried-missing-retry-map-key summary to preserve explicit retried-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":1}" "$explicit_retried_missing_retry_map_key_step_summary"; then
	echo "Expected explicit-retried-missing-retry-map-key summary to synthesize minimum retry-count map entries for explicit retried gates." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 1" "$explicit_retried_missing_retry_map_key_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$explicit_retried_missing_retry_map_key_step_summary"; then
	echo "Expected explicit-retried-missing-retry-map-key summary to derive retry aggregates from synthesized explicit retried map entries." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$explicit_retried_missing_retry_map_key_step_summary"; then
	echo "Expected explicit-retried-missing-retry-map-key summary to include synthesized retried gate in attention fallback." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_retried_missing_retry_map_key_step_summary"; then
	echo "Did not expect schema warning for explicit-retried-missing-retry-map-key summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, build" "$explicit_empty_retried_with_retry_map_step_summary"; then
	echo "Expected explicit-empty-retried-with-retry-map summary to preserve derived gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** none" "$explicit_empty_retried_with_retry_map_step_summary" || ! grep -Fq "**Retried gate count:** 0" "$explicit_empty_retried_with_retry_map_step_summary"; then
	echo "Expected explicit-empty-retried-with-retry-map summary to preserve explicit empty retried-gate override in unscoped payloads." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":0,\"build\":0}" "$explicit_empty_retried_with_retry_map_step_summary"; then
	echo "Expected explicit-empty-retried-with-retry-map summary to zero retry-count map entries when explicit unscoped retried list is empty." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 0" "$explicit_empty_retried_with_retry_map_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$explicit_empty_retried_with_retry_map_step_summary"; then
	echo "Expected explicit-empty-retried-with-retry-map summary to derive zero retry aggregates from explicit empty unscoped retried override." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** none" "$explicit_empty_retried_with_retry_map_step_summary"; then
	echo "Expected explicit-empty-retried-with-retry-map summary to keep attention list clear when explicit unscoped retried list is empty and statuses are pass." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_empty_retried_with_retry_map_step_summary"; then
	echo "Did not expect schema warning for explicit-empty-retried-with-retry-map summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$scalar_failed_gate_with_empty_failed_ids_step_summary"; then
	echo "Expected scalar-failed-gate-with-empty-failed-ids summary to derive selected-gate metadata from scalar failed-gate fallback when failedGateIds is explicitly empty." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates:** 0" "$scalar_failed_gate_with_empty_failed_ids_step_summary" || ! grep -Fq "**Failed gates list:** lint" "$scalar_failed_gate_with_empty_failed_ids_step_summary"; then
	echo "Expected scalar-failed-gate-with-empty-failed-ids summary to preserve explicit empty failed-count metadata while still projecting scalar failed-gate list fallback." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit code:** 7" "$scalar_failed_gate_with_empty_failed_ids_step_summary"; then
	echo "Expected scalar-failed-gate-with-empty-failed-ids summary to preserve scalar failed-gate exit code metadata." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit codes:** 7" "$scalar_failed_gate_with_empty_failed_ids_step_summary" || ! grep -Fq '**Gate exit-code map:** {"lint":7}' "$scalar_failed_gate_with_empty_failed_ids_step_summary"; then
	echo "Expected scalar-failed-gate-with-empty-failed-ids summary to align failed exit-code list/map with scalar failed-gate fallback." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$scalar_failed_gate_with_empty_failed_ids_step_summary" || ! grep -Fq "**Exit reason:** success" "$scalar_failed_gate_with_empty_failed_ids_step_summary"; then
	echo "Expected scalar-failed-gate-with-empty-failed-ids summary to preserve success run-state metadata when explicit failed-count evidence stays zero." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$scalar_failed_gate_with_empty_failed_ids_step_summary"; then
	echo "Did not expect schema warning for scalar-failed-gate-with-empty-failed-ids summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$scalar_failed_gate_selected_fallback_step_summary"; then
	echo "Expected scalar-failed-gate-selected-fallback summary to derive selected-gate metadata from scalar failed-gate identifiers." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 1" "$scalar_failed_gate_selected_fallback_step_summary"; then
	echo "Expected scalar-failed-gate-selected-fallback summary to align gate count with scalar-derived selected gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates list:** lint" "$scalar_failed_gate_selected_fallback_step_summary" || ! grep -Fq "**Failed gate exit code:** 2" "$scalar_failed_gate_selected_fallback_step_summary"; then
	echo "Expected scalar-failed-gate-selected-fallback summary to preserve scalar failed-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$scalar_failed_gate_selected_fallback_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$scalar_failed_gate_selected_fallback_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$scalar_failed_gate_selected_fallback_step_summary"; then
	echo "Expected scalar-failed-gate-selected-fallback summary to derive consistent failure run-state metadata from scalar failed-gate evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$scalar_failed_gate_selected_fallback_step_summary"; then
	echo "Did not expect schema warning for scalar-failed-gate-selected-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$scalar_blocked_gate_selected_fallback_step_summary"; then
	echo "Expected scalar-blocked-gate-selected-fallback summary to derive selected-gate metadata from scalar blocked-by identifiers." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 1" "$scalar_blocked_gate_selected_fallback_step_summary"; then
	echo "Expected scalar-blocked-gate-selected-fallback summary to align gate count with scalar blocked-by selected-gate fallback." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** lint" "$scalar_blocked_gate_selected_fallback_step_summary"; then
	echo "Expected scalar-blocked-gate-selected-fallback summary to preserve scalar blocked-by metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$scalar_blocked_gate_selected_fallback_step_summary" || ! grep -Fq "**Exit reason:** success" "$scalar_blocked_gate_selected_fallback_step_summary" || ! grep -Fq "**Run classification:** success-no-retries" "$scalar_blocked_gate_selected_fallback_step_summary"; then
	echo "Expected scalar-blocked-gate-selected-fallback summary to preserve explicit success run-state metadata when unscoped blocked scalar evidence is present without conflicting outcome evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$scalar_blocked_gate_selected_fallback_step_summary"; then
	echo "Did not expect schema warning for scalar-blocked-gate-selected-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** none" "$scalar_none_sentinel_gate_ids_step_summary"; then
	echo "Expected scalar-none-sentinel-gate-ids summary to ignore scalar 'none' sentinel gate identifiers in selected-gate fallback derivation." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 0" "$scalar_none_sentinel_gate_ids_step_summary" || ! grep -Fq "**Failed gates:** 0" "$scalar_none_sentinel_gate_ids_step_summary"; then
	echo "Expected scalar-none-sentinel-gate-ids summary to keep gate and failed counts clear when scalar sentinels resolve to null." >&2
	exit 1
fi
if ! grep -Fq "**Gate exit-code map:** {}" "$scalar_none_sentinel_gate_ids_step_summary"; then
	echo "Expected scalar-none-sentinel-gate-ids summary to avoid synthesizing 'none' gate IDs in exit-code maps." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** none" "$scalar_none_sentinel_gate_ids_step_summary" || ! grep -Fq "**Blocked by gate:** none" "$scalar_none_sentinel_gate_ids_step_summary"; then
	echo "Expected scalar-none-sentinel-gate-ids summary to normalize scalar failed/blocked 'none' sentinels to absent metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$scalar_none_sentinel_gate_ids_step_summary"; then
	echo "Did not expect schema warning for scalar-none-sentinel-gate-ids summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$scalar_none_sentinel_gate_ids_case_scope_step_summary"; then
	echo "Expected scalar-none-sentinel-gate-ids-case-scope summary to preserve explicit selected-gate metadata while suppressing scalar 'none' sentinels." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates:** 0" "$scalar_none_sentinel_gate_ids_case_scope_step_summary" || ! grep -Fq "**Blocked by gate:** none" "$scalar_none_sentinel_gate_ids_case_scope_step_summary"; then
	echo "Expected scalar-none-sentinel-gate-ids-case-scope summary to ignore case/whitespace scalar 'none' sentinels under selected scope." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit code:** none" "$scalar_none_sentinel_gate_ids_case_scope_step_summary"; then
	echo "Expected scalar-none-sentinel-gate-ids-case-scope summary to suppress failed-gate exit code when failed gate sentinel is ignored." >&2
	exit 1
fi
if grep -Fq "\"none\"" "$scalar_none_sentinel_gate_ids_case_scope_step_summary"; then
	echo "Expected scalar-none-sentinel-gate-ids-case-scope summary to avoid rendering literal 'none' gate IDs in metadata maps." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$scalar_none_sentinel_gate_ids_case_scope_step_summary"; then
	echo "Did not expect schema warning for scalar-none-sentinel-gate-ids-case-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_explicit_attention_scope_step_summary"; then
	echo "Expected selected-explicit-attention-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint" "$selected_explicit_attention_scope_step_summary" || ! grep -Fq "**Attention gates list:** lint" "$selected_explicit_attention_scope_step_summary"; then
	echo "Expected selected-explicit-attention-scope summary to scope explicit non-success/attention lists to selected IDs." >&2
	exit 1
fi
if grep -Fq "build" "$selected_explicit_attention_scope_step_summary"; then
	echo "Expected selected-explicit-attention-scope summary to exclude non-selected explicit non-success/attention IDs from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_attention_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-attention-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_partition_list_overlap_scope_step_summary"; then
	echo "Expected selected-partition-list-overlap-scope summary to preserve explicit selected-gate ordering." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$selected_partition_list_overlap_scope_step_summary" || ! grep -Fq "**Failed gates:** 1" "$selected_partition_list_overlap_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_partition_list_overlap_scope_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$selected_partition_list_overlap_scope_step_summary"; then
	echo "Expected selected-partition-list-overlap-scope summary to normalize overlapping selected partition lists by status-priority." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":0,"not-run":0}' "$selected_partition_list_overlap_scope_step_summary"; then
	echo "Expected selected-partition-list-overlap-scope summary to keep status counts aligned with normalized selected partition lists." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** typecheck" "$selected_partition_list_overlap_scope_step_summary" || ! grep -Fq "**Failed gates list:** lint" "$selected_partition_list_overlap_scope_step_summary" || ! grep -Fq "**Skipped gates list:** none" "$selected_partition_list_overlap_scope_step_summary" || ! grep -Fq "**Not-run gates list:** none" "$selected_partition_list_overlap_scope_step_summary"; then
	echo "Expected selected-partition-list-overlap-scope summary to retain only highest-priority selected partition membership per gate." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_partition_list_overlap_scope_step_summary" || ! grep -Fq "**Executed gates list:** typecheck, lint" "$selected_partition_list_overlap_scope_step_summary"; then
	echo "Expected selected-partition-list-overlap-scope summary to derive executed metadata from normalized selected pass/fail partitions." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint" "$selected_partition_list_overlap_scope_step_summary" || ! grep -Fq "**Attention gates list:** lint" "$selected_partition_list_overlap_scope_step_summary"; then
	echo "Expected selected-partition-list-overlap-scope summary to keep non-success/attention lists aligned with normalized selected partitions." >&2
	exit 1
fi
if grep -Fq "build" "$selected_partition_list_overlap_scope_step_summary"; then
	echo "Expected selected-partition-list-overlap-scope summary to scope out non-selected overlapping partition IDs." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_partition_list_overlap_scope_step_summary"; then
	echo "Did not expect schema warning for selected-partition-list-overlap-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to normalize selected gate IDs via trimming and dedupe." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 2" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Passed gates:** 0" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Failed gates:** 2" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to ignore conflicting scalar counts and derive selected partition counts from normalized selected lists." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":0,"fail":2,"skip":0,"not-run":0}' "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to align status-count metadata with normalized selected partition precedence." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Executed gates list:** typecheck, lint" "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to scope/dedupe explicit executed-gate lists while ignoring conflicting scalar executed count." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** none" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Failed gates list:** lint, typecheck" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Skipped gates list:** none" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Not-run gates list:** none" "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to preserve only highest-priority selected partition membership after malformed-list normalization." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {"lint":"fail","typecheck":"fail"}' "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to derive selected sparse status map from normalized partition lists." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to scope and dedupe explicit retried-gate lists." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint, typecheck" "$selected_partition_list_malformed_counts_scope_step_summary" || ! grep -Fq "**Attention gates list:** typecheck, lint" "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to scope and preserve ordering for explicit non-success/attention gate lists." >&2
	exit 1
fi
if grep -Fq "build" "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Expected selected-partition-list-malformed-counts-scope summary to exclude non-selected malformed list entries from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_partition_list_malformed_counts_scope_step_summary"; then
	echo "Did not expect schema warning for selected-partition-list-malformed-counts-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_explicit_empty_attention_with_retries_scope_step_summary"; then
	echo "Expected selected-explicit-empty-attention-with-retries-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_explicit_empty_attention_with_retries_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_explicit_empty_attention_with_retries_scope_step_summary"; then
	echo "Expected selected-explicit-empty-attention-with-retries-scope summary to preserve selected retried metadata." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** none" "$selected_explicit_empty_attention_with_retries_scope_step_summary"; then
	echo "Expected selected-explicit-empty-attention-with-retries-scope summary to preserve explicit empty attention list override even when selected retried gates exist." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_empty_attention_with_retries_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-empty-attention-with-retries-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_explicit_empty_non_success_with_retries_scope_step_summary"; then
	echo "Expected selected-explicit-empty-non-success-with-retries-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** none" "$selected_explicit_empty_non_success_with_retries_scope_step_summary"; then
	echo "Expected selected-explicit-empty-non-success-with-retries-scope summary to preserve explicit empty non-success override." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$selected_explicit_empty_non_success_with_retries_scope_step_summary"; then
	echo "Expected selected-explicit-empty-non-success-with-retries-scope summary to still include selected retried gates in attention fallback when only non-success list is explicitly empty." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_empty_non_success_with_retries_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-empty-non-success-with-retries-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_explicit_empty_retried_with_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-retried-with-retry-map-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** none" "$selected_explicit_empty_retried_with_retry_map_scope_step_summary" || ! grep -Fq "**Retried gate count:** 0" "$selected_explicit_empty_retried_with_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-retried-with-retry-map-scope summary to preserve explicit empty retried-gate override." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":0}" "$selected_explicit_empty_retried_with_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-retried-with-retry-map-scope summary to zero retry-count map when explicit retried list is empty." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 0" "$selected_explicit_empty_retried_with_retry_map_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$selected_explicit_empty_retried_with_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-retried-with-retry-map-scope summary to derive retry aggregates from scoped retried-gate evidence." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** none" "$selected_explicit_empty_retried_with_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-empty-retried-with-retry-map-scope summary to keep attention list clear when retried-gate override is explicitly empty." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_empty_retried_with_retry_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-empty-retried-with-retry-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_explicit_retried_subset_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-retry-map-scope summary to preserve selected-gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_explicit_retried_subset_retry_map_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_explicit_retried_subset_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-retry-map-scope summary to preserve explicit retried-gate subset override." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 3" "$selected_explicit_retried_subset_retry_map_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 7s" "$selected_explicit_retried_subset_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-retry-map-scope summary to derive retry aggregates from explicit retried-gate subset only." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":3,\"typecheck\":0}" "$selected_explicit_retried_subset_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-retry-map-scope summary to zero retry-count map entries outside selected explicit retried subset." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$selected_explicit_retried_subset_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-retry-map-scope summary to include only explicit retried subset in derived attention list." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_retried_subset_retry_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-retried-subset-retry-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_explicit_retried_zero_count_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-zero-count-retry-map-scope summary to preserve selected-gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_explicit_retried_zero_count_retry_map_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_explicit_retried_zero_count_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-zero-count-retry-map-scope summary to preserve explicit retried-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":1,\"typecheck\":0}" "$selected_explicit_retried_zero_count_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-zero-count-retry-map-scope summary to enforce minimum retry counts for explicit retried gates while zeroing non-retried entries." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 1" "$selected_explicit_retried_zero_count_retry_map_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_explicit_retried_zero_count_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-zero-count-retry-map-scope summary to derive retry aggregates with explicit retried-gate minimums." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$selected_explicit_retried_zero_count_retry_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-zero-count-retry-map-scope summary to keep attention list constrained to explicit retried gates." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_retried_zero_count_retry_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-retried-zero-count-retry-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_explicit_retried_missing_retry_map_key_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_explicit_retried_missing_retry_map_key_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_explicit_retried_missing_retry_map_key_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-scope summary to preserve explicit retried-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":1}" "$selected_explicit_retried_missing_retry_map_key_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-scope summary to synthesize retry-count map entries for selected explicit retried IDs." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 1" "$selected_explicit_retried_missing_retry_map_key_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_explicit_retried_missing_retry_map_key_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-scope summary to derive retry aggregates from synthesized selected explicit retried entries." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$selected_explicit_retried_missing_retry_map_key_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-scope summary to include synthesized selected retried gate in attention fallback." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_retried_missing_retry_map_key_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-retried-missing-retry-map-key-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-with-map-scope summary to preserve selected-gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-with-map-scope summary to preserve explicit retried-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":1" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary" || ! grep -Fq "\"typecheck\":0" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-with-map-scope summary to synthesize missing retried keys and zero non-retried map entries." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 1" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-with-map-scope summary to keep retry aggregates aligned with synthesized selected retried entries." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary"; then
	echo "Expected selected-explicit-retried-missing-retry-map-key-with-map-scope summary to constrain attention list to retried selected entries." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_retried_missing_retry_map_key_with_map_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-retried-missing-retry-map-key-with-map-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$selected_explicit_retried_subset_over_rows_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-over-rows-scope summary to preserve selected-gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$selected_explicit_retried_subset_over_rows_scope_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$selected_explicit_retried_subset_over_rows_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-over-rows-scope summary to preserve explicit retried subset over row retry metadata." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":2,\"typecheck\":0}" "$selected_explicit_retried_subset_over_rows_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-over-rows-scope summary to zero row-derived retry counts outside explicit selected retried subset." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 2" "$selected_explicit_retried_subset_over_rows_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 3s" "$selected_explicit_retried_subset_over_rows_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-over-rows-scope summary to derive retry aggregates from explicit retried subset over row retry counts." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint" "$selected_explicit_retried_subset_over_rows_scope_step_summary"; then
	echo "Expected selected-explicit-retried-subset-over-rows-scope summary to constrain attention list to explicit selected retried subset." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_retried_subset_over_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-retried-subset-over-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$selected_explicit_retried_nonselected_scope_step_summary"; then
	echo "Expected selected-explicit-retried-nonselected-scope summary to preserve selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** none" "$selected_explicit_retried_nonselected_scope_step_summary" || ! grep -Fq "**Retried gate count:** 0" "$selected_explicit_retried_nonselected_scope_step_summary"; then
	echo "Expected selected-explicit-retried-nonselected-scope summary to scope explicit retried IDs to selected gates only." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":0}" "$selected_explicit_retried_nonselected_scope_step_summary"; then
	echo "Expected selected-explicit-retried-nonselected-scope summary to zero retry-count map when explicit retried IDs scope out entirely." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 0" "$selected_explicit_retried_nonselected_scope_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$selected_explicit_retried_nonselected_scope_step_summary"; then
	echo "Expected selected-explicit-retried-nonselected-scope summary to keep retry aggregates zero when explicit retried IDs are all non-selected." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** none" "$selected_explicit_retried_nonselected_scope_step_summary"; then
	echo "Expected selected-explicit-retried-nonselected-scope summary to keep attention list clear when explicit retried IDs are all non-selected." >&2
	exit 1
fi
if grep -Fq "build" "$selected_explicit_retried_nonselected_scope_step_summary"; then
	echo "Expected selected-explicit-retried-nonselected-scope summary to exclude non-selected retried IDs from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_explicit_retried_nonselected_scope_step_summary"; then
	echo "Did not expect schema warning for selected-explicit-retried-nonselected-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** missing-only" "$selected_run_state_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-run-state-unmatched-rows-scope summary to preserve explicit selected-gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$selected_run_state_unmatched_rows_scope_step_summary" || ! grep -Fq "**Exit reason:** completed-with-failures" "$selected_run_state_unmatched_rows_scope_step_summary" || ! grep -Fq "**Run classification:** failed-continued" "$selected_run_state_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-run-state-unmatched-rows-scope summary to preserve explicit run-state when only non-selected rows exist." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$selected_run_state_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-run-state-unmatched-rows-scope summary to preserve explicit continue-on-failure when selected-scope row evidence is absent." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass |' "$selected_run_state_unmatched_rows_scope_step_summary"; then
	echo "Expected selected-run-state-unmatched-rows-scope summary to retain unmatched-selection table fallback rows." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$selected_run_state_unmatched_rows_scope_step_summary"; then
	echo "Did not expect schema warning for selected-run-state-unmatched-rows-scope summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 9" "$unscoped_aggregate_metrics_explicit_precedence_step_summary" || ! grep -Fq "**Total retries:** 13" "$unscoped_aggregate_metrics_explicit_precedence_step_summary" || ! grep -Fq "**Total retry backoff:** 21s" "$unscoped_aggregate_metrics_explicit_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-precedence summary to preserve explicit aggregate retry scalars in unscoped mode." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 30s" "$unscoped_aggregate_metrics_explicit_precedence_step_summary" || ! grep -Fq "**Executed duration average:** 15s" "$unscoped_aggregate_metrics_explicit_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-precedence summary to preserve explicit aggregate duration scalars in unscoped mode." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 77%" "$unscoped_aggregate_metrics_explicit_precedence_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 70%" "$unscoped_aggregate_metrics_explicit_precedence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 88%" "$unscoped_aggregate_metrics_explicit_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-precedence summary to preserve explicit aggregate retry/pass/share rate scalars in unscoped mode." >&2
	exit 1
fi
if grep -Eq '^\*\*Total retries:\*\* 1$' "$unscoped_aggregate_metrics_explicit_precedence_step_summary" || grep -Eq '^\*\*Executed duration total:\*\* 10s$' "$unscoped_aggregate_metrics_explicit_precedence_step_summary" || grep -Eq '^\*\*Retry rate \(executed gates\):\*\* 50%$' "$unscoped_aggregate_metrics_explicit_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-precedence summary to avoid replacing explicit aggregate scalars with derived fallback values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_explicit_precedence_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-explicit-precedence summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 5" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || ! grep -Fq "**Total retries:** 7" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || ! grep -Fq "**Total retry backoff:** 11s" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence summary to preserve explicit retry aggregates even when retry evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 13s" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || ! grep -Fq "**Executed duration average:** 13s" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence summary to preserve explicit duration aggregates even when execution evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 90%" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 84%" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 10%" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence summary to preserve explicit retry/pass/share rates even when execution evidence is absent." >&2
	exit 1
fi
if grep -Fq "**Retried gate count:** 0" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || grep -Fq "**Total retries:** 0" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || grep -Fq "**Total retry backoff:** 0s" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || grep -Fq "**Executed duration total:** 0s" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary" || grep -Fq "**Executed duration average:** n/a" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence summary to avoid replacing explicit aggregate scalars with no-evidence fallback values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_explicit_no_evidence_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-explicit-no-evidence summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 5" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" || ! grep -Fq "**Total retries:** 7" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" || ! grep -Fq "**Total retry backoff:** 11s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string summary to preserve explicit numeric-string retry aggregates when evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 13s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" || ! grep -Fq "**Executed duration average:** 13s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string summary to preserve explicit numeric-string duration aggregates when evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 90%" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 84%" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 10%" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string summary to preserve explicit numeric-string retry/pass/share rates when evidence is absent." >&2
	exit 1
fi
if grep -Fq "**Retried gate count:** 0" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" || grep -Fq "**Total retries:** 0" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" || grep -Fq "**Total retry backoff:** 0s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary" || grep -Fq "**Executed duration total:** 0s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string summary to avoid replacing explicit numeric-string aggregates with no-evidence fallback values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_explicit_no_evidence_string_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-explicit-no-evidence-string summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 5" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" || ! grep -Fq "**Total retries:** 7" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" || ! grep -Fq "**Total retry backoff:** 11s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string-whitespace summary to preserve trimmed numeric-string retry aggregates when evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 13s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" || ! grep -Fq "**Executed duration average:** 13s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string-whitespace summary to preserve trimmed numeric-string duration aggregates when evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 90%" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 84%" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 10%" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string-whitespace summary to preserve trimmed numeric-string retry/pass/share rates when evidence is absent." >&2
	exit 1
fi
if grep -Fq "**Retried gate count:** 0" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" || grep -Fq "**Total retries:** 0" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" || grep -Fq "**Total retry backoff:** 0s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary" || grep -Fq "**Executed duration total:** 0s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string-whitespace summary to avoid replacing trimmed numeric-string aggregates with no-evidence fallback values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_explicit_no_evidence_string_whitespace_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-explicit-no-evidence-string-whitespace summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary" || ! grep -Fq "**Total retries:** 0" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string-plus summary to ignore plus-prefixed numeric-string retry aggregates when evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 0s" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary" || ! grep -Fq "**Executed duration average:** n/a" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string-plus summary to ignore plus-prefixed numeric-string duration aggregates when evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string-plus summary to ignore plus-prefixed numeric-string rate aggregates when evidence is absent." >&2
	exit 1
fi
if grep -Fq "+13" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary" || grep -Fq "+90%" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary" || grep -Fq "+7" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-explicit-no-evidence-string-plus summary to suppress plus-prefixed numeric-string aggregate literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_explicit_no_evidence_string_plus_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-explicit-no-evidence-string-plus summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || ! grep -Fq "**Total retries:** 0" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-no-evidence-mixed-invalid summary to ignore mixed invalid retry scalars and render no-evidence fallback metrics." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 0s" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || ! grep -Fq "**Executed duration average:** n/a" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-no-evidence-mixed-invalid summary to ignore mixed invalid duration scalars and render no-evidence fallback metrics." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-no-evidence-mixed-invalid summary to ignore mixed invalid rate scalars and render no-evidence fallback metrics." >&2
	exit 1
fi
if grep -Fq "7.5" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || grep -Fq "7e1" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || grep -Fq "11.5" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || grep -Fq "13.5" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || grep -Fq "13e1" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || grep -Fq "90.5" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary" || grep -Fq "84e1" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-no-evidence-mixed-invalid summary to suppress mixed invalid scalar literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_no_evidence_mixed_invalid_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-no-evidence-mixed-invalid summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary" || ! grep -Fq "**Total retries:** 1" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-decimal-string-fallback summary to ignore decimal-string retry scalars and derive retry metrics." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 10s" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary" || ! grep -Fq "**Executed duration average:** 5s" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-decimal-string-fallback summary to ignore decimal-string duration scalars and derive duration metrics." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 10%" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-decimal-string-fallback summary to ignore decimal-string rate scalars and derive rate metrics." >&2
	exit 1
fi
if grep -Fq "13.5" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary" || grep -Fq "30.5" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary" || grep -Fq "77.5%" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-decimal-string-fallback summary to suppress decimal-string scalar literals in rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_decimal_string_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-decimal-string-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary" || ! grep -Fq "**Total retries:** 1" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-float-scalar-fallback summary to ignore float retry scalars and derive retry metrics." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 10s" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary" || ! grep -Fq "**Executed duration average:** 5s" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-float-scalar-fallback summary to ignore float duration scalars and derive duration metrics." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 10%" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-float-scalar-fallback summary to ignore float rate scalars and derive rate metrics." >&2
	exit 1
fi
if grep -Fq "13.5" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary" || grep -Fq "30.5" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary" || grep -Fq "77.5%" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-float-scalar-fallback summary to suppress float scalar values in rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_float_scalar_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-float-scalar-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary" || ! grep -Fq "**Total retries:** 1" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-scientific-string-fallback summary to ignore scientific-notation retry scalars and derive retry metrics." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 10s" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary" || ! grep -Fq "**Executed duration average:** 5s" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-scientific-string-fallback summary to ignore scientific-notation duration scalars and derive duration metrics." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 10%" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-scientific-string-fallback summary to ignore scientific-notation rate scalars and derive rate metrics." >&2
	exit 1
fi
if grep -Fq "13e1" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary" || grep -Fq "30e1" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary" || grep -Fq "77e1" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-scientific-string-fallback summary to suppress scientific-notation scalar values in rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_scientific_string_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-scientific-string-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 9" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary" || ! grep -Fq "**Total retries:** 13" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary" || ! grep -Fq "**Total retry backoff:** 21s" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-string-scalar-precedence summary to normalize trimmed numeric-string retry scalars." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 30s" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary" || ! grep -Fq "**Executed duration average:** 15s" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-string-scalar-precedence summary to normalize trimmed numeric-string duration scalars." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 77%" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 70%" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 88%" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-string-scalar-precedence summary to normalize trimmed numeric-string rate scalars." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_string_scalar_precedence_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-string-scalar-precedence summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary" || ! grep -Fq "**Total retries:** 9" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-partial-scalar-precedence summary to apply retry scalar precedence per field (explicit totals preserved, malformed fields re-derived)." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 30s" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary" || ! grep -Fq "**Executed duration average:** 15s" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-partial-scalar-precedence summary to preserve explicit executed duration total while deriving average from resolved totals/counts." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 3%" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 88%" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-partial-scalar-precedence summary to preserve explicit pass-rate scalar while deriving retry/share rates from resolved metrics." >&2
	exit 1
fi
if grep -Fq "**Total retries:** 1" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary" || grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-partial-scalar-precedence summary to avoid replacing explicit per-field scalar overrides with derived defaults." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_partial_scalar_precedence_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-partial-scalar-precedence summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$unscoped_aggregate_metrics_negative_fallback_step_summary" || ! grep -Fq "**Total retries:** 1" "$unscoped_aggregate_metrics_negative_fallback_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$unscoped_aggregate_metrics_negative_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-negative-fallback summary to ignore negative aggregate retry scalars and derive retry metrics." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 10s" "$unscoped_aggregate_metrics_negative_fallback_step_summary" || ! grep -Fq "**Executed duration average:** 5s" "$unscoped_aggregate_metrics_negative_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-negative-fallback summary to ignore negative aggregate duration scalars and derive duration metrics." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$unscoped_aggregate_metrics_negative_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 10%" "$unscoped_aggregate_metrics_negative_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_aggregate_metrics_negative_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-negative-fallback summary to ignore negative aggregate rate scalars and derive rate metrics." >&2
	exit 1
fi
if grep -Fq -- "-13" "$unscoped_aggregate_metrics_negative_fallback_step_summary" || grep -Fq -- "-30s" "$unscoped_aggregate_metrics_negative_fallback_step_summary" || grep -Fq -- "-77%" "$unscoped_aggregate_metrics_negative_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-negative-fallback summary to suppress negative aggregate scalar values from rendered metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_negative_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-negative-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$unscoped_aggregate_metrics_malformed_fallback_step_summary" || ! grep -Fq "**Total retries:** 1" "$unscoped_aggregate_metrics_malformed_fallback_step_summary" || ! grep -Fq "**Total retry backoff:** 1s" "$unscoped_aggregate_metrics_malformed_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-malformed-fallback summary to ignore malformed aggregate retry scalars and derive retry metrics." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 10s" "$unscoped_aggregate_metrics_malformed_fallback_step_summary" || ! grep -Fq "**Executed duration average:** 5s" "$unscoped_aggregate_metrics_malformed_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-malformed-fallback summary to ignore malformed aggregate duration scalars and derive duration metrics." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$unscoped_aggregate_metrics_malformed_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 10%" "$unscoped_aggregate_metrics_malformed_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_aggregate_metrics_malformed_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-malformed-fallback summary to ignore malformed aggregate rate scalars and derive rate metrics." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_malformed_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-malformed-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 0" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary" || ! grep -Fq "**Total retries:** 0" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary" || ! grep -Fq "**Total retry backoff:** 0s" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-malformed-no-evidence-fallback summary to normalize malformed aggregate retry scalars to zero-valued fallback metrics when retry evidence is absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 0s" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary" || ! grep -Fq "**Executed duration average:** n/a" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-malformed-no-evidence-fallback summary to normalize malformed aggregate duration scalars to no-evidence fallback values." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-malformed-no-evidence-fallback summary to normalize malformed aggregate rate scalars to n/a when executed-gate evidence is absent." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_malformed_no_evidence_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-malformed-no-evidence-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 10%" "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-overflow-fallback summary to ignore overflow explicit rate scalars (>100) and derive bounded rates from normalized metrics." >&2
	exit 1
fi
if grep -Fq "150%" "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary" || grep -Fq "140%" "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary" || grep -Fq "120%" "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-overflow-fallback summary to suppress overflow explicit rate scalar literals." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_rate_scalar_overflow_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-rate-scalar-overflow-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-overflow-no-evidence-fallback summary to reject overflow rate scalars and preserve sparse no-evidence n/a defaults." >&2
	exit 1
fi
if grep -Fq "150%" "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary" || grep -Fq "140%" "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary" || grep -Fq "120%" "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-overflow-no-evidence-fallback summary to suppress overflow numeric-string rate scalar literals in sparse payloads." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_rate_scalar_overflow_no_evidence_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-rate-scalar-overflow-no-evidence-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 100%" "$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-upper-bound-precedence summary to preserve explicit upper-bound 100% rate scalars in sparse no-evidence payloads." >&2
	exit 1
fi
if grep -Fq "**Retry rate (executed gates):** n/a" "$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_step_summary" || grep -Fq "**Pass rate (executed gates):** n/a" "$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-upper-bound-precedence summary to avoid replacing explicit 100% rate scalars with no-evidence fallback values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_rate_scalar_upper_bound_precedence_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-rate-scalar-upper-bound-precedence summary." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 0%" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-precedence summary to preserve valid boundary explicit rates while normalizing overflow fields to sparse n/a fallback." >&2
	exit 1
fi
if grep -Fq "101%" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_step_summary" || grep -Fq "**Retry rate (executed gates):** n/a" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-precedence summary to suppress overflow literals and retain valid boundary explicit values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_no_evidence_precedence_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-rate-scalar-mixed-boundary-no-evidence-precedence summary." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 5" "$unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_step_summary" || ! grep -Fq "**Executed gates:** 1" "$unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-retry-rate-scalar-count-clamp-fallback summary to preserve conflicting scalar retried count inputs for diagnostic visibility." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-retry-rate-scalar-count-clamp-fallback summary to clamp retry-rate derivation to 100% when scalar retried counts exceed executed counts." >&2
	exit 1
fi
if grep -Fq "500%" "$unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-retry-rate-scalar-count-clamp-fallback summary to suppress unclamped retry-rate values above 100%." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_retry_rate_scalar_count_clamp_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-retry-rate-scalar-count-clamp-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 0%" "$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 0%" "$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 0%" "$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-lower-bound-precedence summary to preserve explicit lower-bound 0% rate scalars when derived rates are non-zero." >&2
	exit 1
fi
if grep -Fq "**Retry rate (executed gates):** 50%" "$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_step_summary" || grep -Fq "**Retry backoff share (executed duration):** 10%" "$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-lower-bound-precedence summary to avoid replacing explicit 0% rate scalars with derived defaults." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_rate_scalar_lower_bound_precedence_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-rate-scalar-lower-bound-precedence summary." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 10%" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 0%" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-mixed-boundary-precedence summary to preserve valid boundary rate scalars while deriving overflow fields from normalized evidence." >&2
	exit 1
fi
if grep -Fq "101%" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_step_summary" || grep -Fq "50%" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-scalar-mixed-boundary-precedence summary to suppress overflow scalar literals and avoid replacing valid boundary scalar overrides with derived defaults." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_rate_scalar_mixed_boundary_precedence_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-rate-scalar-mixed-boundary-precedence summary." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 5" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary" || ! grep -Fq "**Executed gates:** 1" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-derived-clamp-fallback summary to preserve conflicting sparse count inputs for diagnostic visibility." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 100%" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** 100%" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-derived-clamp-fallback summary to clamp derived rates at 100% when sparse ratios exceed 100%." >&2
	exit 1
fi
if grep -Fq "500%" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary" || grep -Fq "700%" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary"; then
	echo "Expected unscoped-aggregate-metrics-rate-derived-clamp-fallback summary to suppress unclamped sparse derived rate values above 100%." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_aggregate_metrics_rate_derived_clamp_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-aggregate-metrics-rate-derived-clamp-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 4" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive gate count from selectedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive passed gate count from passedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed gate count from failedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit codes:** 2" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed gate exit codes from failedGateIds + gateExitCodeById." >&2
	exit 1
fi
if grep -Fq "999" "$derived_lists_step_summary"; then
	echo "Did not expect extra failed gate exit codes beyond failed gate IDs." >&2
	exit 1
fi
if ! grep -Fq "**Skipped gates:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive skipped gate count from skippedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Not-run gates:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive not-run gate count from notRunGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Status counts:** {\"pass\":1,\"fail\":1,\"skip\":1,\"not-run\":1}" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive statusCounts map from gate-id lists." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":\"pass\"" "$derived_lists_step_summary" || ! grep -Fq "\"typecheck\":\"fail\"" "$derived_lists_step_summary" || ! grep -Fq "\"test-unit\":\"skip\"" "$derived_lists_step_summary" || ! grep -Fq "\"build\":\"not-run\"" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive gate status map from gate-id partitions." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":null" "$derived_lists_step_summary" || ! grep -Fq "\"typecheck\":2" "$derived_lists_step_summary" || ! grep -Fq "\"test-unit\":null" "$derived_lists_step_summary" || ! grep -Fq "\"build\":null" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive normalized gate exit-code map values from failedGateIds + failedGateExitCodes." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive executed gate count from executedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":1,\"typecheck\":0,\"test-unit\":0,\"build\":0}" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive gate retry-count map from retriedGateIds when retry map is omitted." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive total retries from retriedGateIds fallback map." >&2
	exit 1
fi
if ! grep -Fq "**Total retry backoff:** 1s" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retry backoff from retry counts." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retried gate count from retry map." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retried gate IDs from retry map." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retry rate from executed/retried counts." >&2
	exit 1
fi
if ! grep -Fq "**Pass rate (executed gates):** 50%" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive pass rate from executed/passed counts." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck, test-unit, build" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive non-success gates list from partition/status data." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint, typecheck, test-unit, build" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive attention gates list from non-success and retried gates." >&2
	exit 1
fi
if ! grep -Fq "**Retry backoff share (executed duration):** 12%" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retry-backoff share from derived totals." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 8s" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive executed duration total from gateDuration map." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration average:** 4s" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive average executed duration." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate:** lint" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive slowest executed gate." >&2
	exit 1
fi
if ! grep -Fq "**Fastest executed gate:** typecheck" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive fastest executed gate." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** typecheck" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive blocked-by gate from not-run reasons." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** typecheck" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed gate pointer from failedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit code:** 2" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed gate exit code from failedGateIds + gateExitCodeById." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 8s" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive total duration from gate duration map." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$derived_lists_step_summary" || ! grep -Fq "**Completed:** unknown" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to keep started/completed unknown without gate timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive continue-on-failure=false for fail-fast runs." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive fail-fast exit reason from blocked gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed-fail-fast run classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_lists_step_summary"; then
	echo "Did not expect schema warning for derived-list fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, deploy" "$unscoped_partition_scalar_counts_precedence_step_summary" || ! grep -Fq "**Gate count:** 4" "$unscoped_partition_scalar_counts_precedence_step_summary"; then
	echo "Expected unscoped-partition-scalar-counts-precedence summary to preserve sparse partition gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 5" "$unscoped_partition_scalar_counts_precedence_step_summary" || ! grep -Fq "**Failed gates:** 4" "$unscoped_partition_scalar_counts_precedence_step_summary" || ! grep -Fq "**Skipped gates:** 3" "$unscoped_partition_scalar_counts_precedence_step_summary" || ! grep -Fq "**Not-run gates:** 2" "$unscoped_partition_scalar_counts_precedence_step_summary"; then
	echo "Expected unscoped-partition-scalar-counts-precedence summary to keep explicit unscoped partition-count scalars authoritative over sparse partition list lengths." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":5,"fail":4,"skip":3,"not-run":2}' "$unscoped_partition_scalar_counts_precedence_step_summary"; then
	echo "Expected unscoped-partition-scalar-counts-precedence summary to mirror explicit unscoped scalar partition counts in rendered status-count metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** lint" "$unscoped_partition_scalar_counts_precedence_step_summary" || ! grep -Fq "**Failed gates list:** typecheck" "$unscoped_partition_scalar_counts_precedence_step_summary" || ! grep -Fq "**Skipped gates list:** build" "$unscoped_partition_scalar_counts_precedence_step_summary" || ! grep -Fq "**Not-run gates list:** deploy" "$unscoped_partition_scalar_counts_precedence_step_summary"; then
	echo "Expected unscoped-partition-scalar-counts-precedence summary to preserve sparse partition list labels while count scalars remain authoritative." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_partition_scalar_counts_precedence_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_partition_scalar_counts_precedence_step_summary"; then
	echo "Expected unscoped-partition-scalar-counts-precedence summary to derive executed metadata from sparse pass/fail lists while pass-rate uses scalar pass-count precedence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_scalar_counts_precedence_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-scalar-counts-precedence summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, deploy" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary" || ! grep -Fq "**Gate count:** 4" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-vs-status-counts-conflict summary to preserve sparse partition gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 9" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary" || ! grep -Fq "**Failed gates:** 8" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary" || ! grep -Fq "**Skipped gates:** 7" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary" || ! grep -Fq "**Not-run gates:** 6" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-vs-status-counts-conflict summary to keep valid partition-count scalars authoritative over conflicting raw statusCounts for count fields." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":2,"skip":3,"not-run":4}' "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-vs-status-counts-conflict summary to preserve explicit raw statusCounts metadata when provided." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-vs-status-counts-conflict summary to derive executed metadata from sparse pass/fail lists while scalar pass-count precedence drives pass-rate clamping." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_scalar_vs_status_counts_conflict_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-scalar-vs-status-counts-conflict summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, deploy" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary" || ! grep -Fq "**Gate count:** 4" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-zero-raw-status-counts-conflict summary to preserve sparse partition gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 9" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary" || ! grep -Fq "**Failed gates:** 8" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary" || ! grep -Fq "**Skipped gates:** 7" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary" || ! grep -Fq "**Not-run gates:** 6" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-zero-raw-status-counts-conflict summary to keep valid partition-count scalars authoritative over explicit zero raw statusCounts for count fields." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":0,"fail":0,"skip":0,"not-run":0}' "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-zero-raw-status-counts-conflict summary to preserve explicit zero raw statusCounts metadata when provided." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-zero-raw-status-counts-conflict summary to derive executed metadata from sparse pass/fail lists while scalar pass-count precedence still drives pass-rate clamping." >&2
	exit 1
fi
if grep -Fq '**Status counts:** {"pass":9,' "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary"; then
	echo "Expected unscoped-partition-scalar-zero-raw-status-counts-conflict summary to prevent scalar partition counts from overwriting explicit zero raw statusCounts map metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_scalar_zero_raw_status_counts_conflict_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-scalar-zero-raw-status-counts-conflict summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" || ! grep -Fq "**Gate count:** 3" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-zero-raw-status-counts-mix summary to preserve sparse gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 5" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" || ! grep -Fq "**Failed gates:** 1" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" || ! grep -Fq "**Skipped gates:** 4" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-zero-raw-status-counts-mix summary to merge scalar and list fallback count lines while malformed branches fall through." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":0,"fail":1,"skip":0,"not-run":1}' "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-zero-raw-status-counts-mix summary to keep explicit zero/raw statusCounts fields authoritative while unresolved fields fall back per status key." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-zero-raw-status-counts-mix summary to keep executed metadata deterministic while scalar pass-count precedence drives pass-rate clamping." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** lint" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" || ! grep -Fq "**Failed gates list:** typecheck" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" || ! grep -Fq "**Not-run gates list:** build" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-zero-raw-status-counts-mix summary to preserve sparse partition labels while mixed scalar/raw precedence is applied." >&2
	exit 1
fi
if grep -Fq '**Status counts:** {"pass":5,' "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary" || grep -Fq '"skip":4' "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-zero-raw-status-counts-mix summary to prevent scalar partition counts from leaking into explicit zero raw statusCounts map keys." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_scalar_partial_zero_raw_status_counts_mix_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-scalar-partial-zero-raw-status-counts-mix summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, deploy" "$unscoped_partition_scalar_partial_mix_step_summary" || ! grep -Fq "**Gate count:** 4" "$unscoped_partition_scalar_partial_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-mix summary to preserve sparse partition gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 4" "$unscoped_partition_scalar_partial_mix_step_summary" || ! grep -Fq "**Failed gates:** 3" "$unscoped_partition_scalar_partial_mix_step_summary" || ! grep -Fq "**Skipped gates:** 2" "$unscoped_partition_scalar_partial_mix_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$unscoped_partition_scalar_partial_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-mix summary to resolve per-field count precedence across valid scalars, malformed scalars, and valid raw statusCounts." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":4,"fail":3,"skip":2,"not-run":1}' "$unscoped_partition_scalar_partial_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-mix summary to merge raw statusCounts and fallback count fields per status-key." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_partition_scalar_partial_mix_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_partition_scalar_partial_mix_step_summary"; then
	echo "Expected unscoped-partition-scalar-partial-mix summary to keep executed metadata deterministic while clamping mixed-source pass-rate derivation." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_scalar_partial_mix_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-scalar-partial-mix summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, test-unit, build, deploy, package" "$unscoped_partition_scalar_raw_list_hybrid_step_summary" || ! grep -Fq "**Gate count:** 6" "$unscoped_partition_scalar_raw_list_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-hybrid summary to preserve sparse partition gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 4" "$unscoped_partition_scalar_raw_list_hybrid_step_summary" || ! grep -Fq "**Failed gates:** 3" "$unscoped_partition_scalar_raw_list_hybrid_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$unscoped_partition_scalar_raw_list_hybrid_step_summary" || ! grep -Fq "**Not-run gates:** 2" "$unscoped_partition_scalar_raw_list_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-hybrid summary to resolve per-field count precedence across scalar/raw/list fallback branches." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":4,"fail":3,"skip":1,"not-run":2}' "$unscoped_partition_scalar_raw_list_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-hybrid summary to render merged per-field status-count precedence metadata." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 3" "$unscoped_partition_scalar_raw_list_hybrid_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_partition_scalar_raw_list_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-hybrid summary to derive executed metadata from sparse partition lists while clamping mixed-source pass-rate derivation." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_scalar_raw_list_hybrid_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-scalar-raw-list-hybrid summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, test-unit, build, deploy, package" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary" || ! grep -Fq "**Gate count:** 6" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-status-map-hybrid summary to preserve merged sparse gate metadata across list and status-map evidence." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 4" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary" || ! grep -Fq "**Failed gates:** 3" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary" || ! grep -Fq "**Not-run gates:** 2" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-status-map-hybrid summary to resolve per-field count precedence across scalar/raw/list/status-map fallback layers." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":4,"fail":3,"skip":1,"not-run":2}' "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-status-map-hybrid summary to render merged per-field status-count precedence metadata." >&2
	exit 1
fi
if ! grep -Fq "**Not-run gates list:** deploy, package" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-status-map-hybrid summary to derive not-run list fallback from status-map evidence when notRunGateIds are absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 3" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary"; then
	echo "Expected unscoped-partition-scalar-raw-list-status-map-hybrid summary to keep executed metadata deterministic while clamping mixed-source pass-rate derivation." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_scalar_raw_list_status_map_hybrid_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-scalar-raw-list-status-map-hybrid summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build, test-unit, e2e, docs" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" || ! grep -Fq "**Gate count:** 6" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary"; then
	echo "Expected unscoped-partition-scalar-invalid-fallback-status-counts summary to preserve sparse partition gate ordering metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 3" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" || ! grep -Fq "**Failed gates:** 2" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary"; then
	echo "Expected unscoped-partition-scalar-invalid-fallback-status-counts summary to ignore malformed unscoped partition-count scalars and fall back to valid raw statusCounts fields." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":3,"fail":2,"skip":1,"not-run":0}' "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary"; then
	echo "Expected unscoped-partition-scalar-invalid-fallback-status-counts summary to preserve valid raw statusCounts metadata when partition-count scalars are malformed." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** lint, typecheck, build" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" || ! grep -Fq "**Failed gates list:** test-unit, e2e" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" || ! grep -Fq "**Skipped gates list:** docs" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" || ! grep -Fq "**Not-run gates list:** none" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary"; then
	echo "Expected unscoped-partition-scalar-invalid-fallback-status-counts summary to keep sparse partition list labels aligned with valid raw status-count fallback." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 5" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 60%" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary"; then
	echo "Expected unscoped-partition-scalar-invalid-fallback-status-counts summary to derive executed metadata from sparse pass/fail evidence with fallback pass-count denominator semantics." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_scalar_invalid_fallback_status_counts_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-scalar-invalid-fallback-status-counts summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, docs" "$unscoped_status_counts_partial_status_map_fallback_step_summary" || ! grep -Fq "**Gate count:** 3" "$unscoped_status_counts_partial_status_map_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-status-map-fallback summary to preserve sparse gate ordering from status-map evidence." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$unscoped_status_counts_partial_status_map_fallback_step_summary" || ! grep -Fq "**Failed gates:** 3" "$unscoped_status_counts_partial_status_map_fallback_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$unscoped_status_counts_partial_status_map_fallback_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$unscoped_status_counts_partial_status_map_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-status-map-fallback summary to merge valid raw fail status-count with status-map fallback for remaining fields." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":3,"skip":0,"not-run":1}' "$unscoped_status_counts_partial_status_map_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-status-map-fallback summary to render per-field raw/status-map merged statusCounts metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** lint" "$unscoped_status_counts_partial_status_map_fallback_step_summary" || ! grep -Fq "**Failed gates list:** typecheck" "$unscoped_status_counts_partial_status_map_fallback_step_summary" || ! grep -Fq "**Not-run gates list:** docs" "$unscoped_status_counts_partial_status_map_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-status-map-fallback summary to derive sparse partition list labels from status-map evidence while raw fail counter remains authoritative." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_status_counts_partial_status_map_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_status_counts_partial_status_map_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-status-map-fallback summary to derive executed/pass-rate metadata from status-map evidence under merged status-count precedence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_status_counts_partial_status_map_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-status-counts-partial-status-map-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 3" "$unscoped_status_counts_zero_authoritative_step_summary"; then
	echo "Expected unscoped-status-counts-zero-authoritative summary to derive gate count from status-map evidence while explicit zero raw statusCounts remain authoritative." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 0" "$unscoped_status_counts_zero_authoritative_step_summary" || ! grep -Fq "**Failed gates:** 0" "$unscoped_status_counts_zero_authoritative_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$unscoped_status_counts_zero_authoritative_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$unscoped_status_counts_zero_authoritative_step_summary"; then
	echo "Expected unscoped-status-counts-zero-authoritative summary to preserve explicit zero raw statusCounts for all partition counters despite sparse status-map evidence." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":0,"fail":0,"skip":0,"not-run":0}' "$unscoped_status_counts_zero_authoritative_step_summary"; then
	echo "Expected unscoped-status-counts-zero-authoritative summary to keep raw zero statusCounts values authoritative across rendered status map totals." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** lint" "$unscoped_status_counts_zero_authoritative_step_summary" || ! grep -Fq "**Failed gates list:** typecheck" "$unscoped_status_counts_zero_authoritative_step_summary" || ! grep -Fq "**Not-run gates list:** docs" "$unscoped_status_counts_zero_authoritative_step_summary"; then
	echo "Expected unscoped-status-counts-zero-authoritative summary to continue deriving sparse partition list labels from status-map evidence while zero status-count scalars remain authoritative." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_status_counts_zero_authoritative_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 0%" "$unscoped_status_counts_zero_authoritative_step_summary"; then
	echo "Expected unscoped-status-counts-zero-authoritative summary to keep executed metadata status-map-derived while pass-rate remains anchored to explicit zero pass-count raw statusCounts." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck, docs" "$unscoped_status_counts_zero_authoritative_step_summary" || ! grep -Fq "**Attention gates list:** typecheck, docs" "$unscoped_status_counts_zero_authoritative_step_summary"; then
	echo "Expected unscoped-status-counts-zero-authoritative summary to preserve non-success/attention derivation from sparse status-map evidence under explicit zero raw statusCounts." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_status_counts_zero_authoritative_step_summary"; then
	echo "Did not expect schema warning for unscoped-status-counts-zero-authoritative summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 3" "$unscoped_status_counts_partial_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-fallback summary to derive gate count from sparse partition IDs." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 2" "$unscoped_status_counts_partial_fallback_step_summary" || ! grep -Fq "**Failed gates:** 1" "$unscoped_status_counts_partial_fallback_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$unscoped_status_counts_partial_fallback_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$unscoped_status_counts_partial_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-fallback summary to preserve valid raw statusCounts fields while malformed fields fall back to sparse partition evidence." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":2,"fail":1,"skip":1,"not-run":1}' "$unscoped_status_counts_partial_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-fallback summary to render per-field mixed raw/fallback statusCounts metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** lint" "$unscoped_status_counts_partial_fallback_step_summary" || ! grep -Fq "**Failed gates list:** typecheck" "$unscoped_status_counts_partial_fallback_step_summary" || ! grep -Fq "**Not-run gates list:** build" "$unscoped_status_counts_partial_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-fallback summary to preserve sparse partition list labels while mixed status-count precedence is applied." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_status_counts_partial_fallback_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 100%" "$unscoped_status_counts_partial_fallback_step_summary"; then
	echo "Expected unscoped-status-counts-partial-fallback summary to derive executed metadata from sparse pass/fail evidence while pass-rate uses preserved pass-count scalar precedence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_status_counts_partial_fallback_step_summary"; then
	echo "Did not expect schema warning for unscoped-status-counts-partial-fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 3" "$unscoped_partition_list_overlap_step_summary"; then
	echo "Expected unscoped-partition-list-overlap summary to derive gate count from normalized sparse partition IDs." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$unscoped_partition_list_overlap_step_summary" || ! grep -Fq "**Failed gates:** 1" "$unscoped_partition_list_overlap_step_summary" || ! grep -Fq "**Skipped gates:** 1" "$unscoped_partition_list_overlap_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$unscoped_partition_list_overlap_step_summary"; then
	echo "Expected unscoped-partition-list-overlap summary to normalize overlapping sparse partition counts by status-priority." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":1,"skip":1,"not-run":0}' "$unscoped_partition_list_overlap_step_summary"; then
	echo "Expected unscoped-partition-list-overlap summary to align statusCounts with normalized sparse partition memberships." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** typecheck" "$unscoped_partition_list_overlap_step_summary" || ! grep -Fq "**Failed gates list:** lint" "$unscoped_partition_list_overlap_step_summary" || ! grep -Fq "**Skipped gates list:** build" "$unscoped_partition_list_overlap_step_summary" || ! grep -Fq "**Not-run gates list:** none" "$unscoped_partition_list_overlap_step_summary"; then
	echo "Expected unscoped-partition-list-overlap summary to keep each sparse gate in only its highest-priority partition list." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_partition_list_overlap_step_summary" || ! grep -Fq "**Executed gates list:** typecheck, lint" "$unscoped_partition_list_overlap_step_summary"; then
	echo "Expected unscoped-partition-list-overlap summary to derive executed sparse metadata from normalized pass/fail partitions." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint, build" "$unscoped_partition_list_overlap_step_summary" || ! grep -Fq "**Attention gates list:** lint, build" "$unscoped_partition_list_overlap_step_summary"; then
	echo "Expected unscoped-partition-list-overlap summary to align non-success/attention lists with normalized sparse partition outcomes." >&2
	exit 1
fi
if grep -Fq "**Not-run gates list:** lint" "$unscoped_partition_list_overlap_step_summary" || grep -Fq "**Passed gates list:** lint" "$unscoped_partition_list_overlap_step_summary"; then
	echo "Expected unscoped-partition-list-overlap summary to suppress lower-priority overlapping sparse partition memberships." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_list_overlap_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-list-overlap summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 4" "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Expected unscoped-partition-list-malformed-counts summary to derive gate count from normalized sparse gate IDs when scalar gateCount is malformed." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Failed gates:** 2" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Expected unscoped-partition-list-malformed-counts summary to ignore malformed scalar partition counts and derive counts from normalized sparse partition lists." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":1,"fail":2,"skip":0,"not-run":1}' "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Expected unscoped-partition-list-malformed-counts summary to align status counts with normalized sparse partition outcomes when raw statusCounts values are malformed." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** typecheck" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Failed gates list:** lint, build" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Skipped gates list:** none" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Not-run gates list:** deploy" "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Expected unscoped-partition-list-malformed-counts summary to trim/dedupe malformed sparse partition lists and retain highest-priority memberships." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 3" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Executed gates list:** typecheck, lint, build" "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Expected unscoped-partition-list-malformed-counts summary to derive executed metadata from normalized sparse pass/fail memberships when executedGateCount scalar is malformed." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** typecheck, build" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Retried gate count:** 2" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Total retries:** 3" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Total retry backoff:** 4s" "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Expected unscoped-partition-list-malformed-counts summary to trim/dedupe explicit retried lists and derive retry aggregates from normalized retry-count map evidence." >&2
	exit 1
fi
if ! grep -Fq '**Gate retry-count map:** {"typecheck":2,"build":1,"lint":0,"deploy":0}' "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Expected unscoped-partition-list-malformed-counts summary to normalize sparse retry-count maps and apply known-gate defaults for malformed entries." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint, deploy, build" "$unscoped_partition_list_malformed_counts_step_summary" || ! grep -Fq "**Attention gates list:** typecheck, deploy, build" "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Expected unscoped-partition-list-malformed-counts summary to trim/dedupe malformed explicit non-success and attention lists while preserving explicit ordering." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_partition_list_malformed_counts_step_summary"; then
	echo "Did not expect schema warning for unscoped-partition-list-malformed-counts summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 2" "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Expected unscoped-explicit-empty-partition-lists-status-map summary to preserve gate count from status-map IDs when partition lists are explicitly empty." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 0" "$unscoped_explicit_empty_partition_lists_status_map_step_summary" || ! grep -Fq "**Failed gates:** 0" "$unscoped_explicit_empty_partition_lists_status_map_step_summary" || ! grep -Fq "**Skipped gates:** 0" "$unscoped_explicit_empty_partition_lists_status_map_step_summary" || ! grep -Fq "**Not-run gates:** 0" "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Expected unscoped-explicit-empty-partition-lists-status-map summary to keep explicit empty unscoped partition lists authoritative for partition counts." >&2
	exit 1
fi
if ! grep -Fq '**Status counts:** {"pass":0,"fail":0,"skip":0,"not-run":0}' "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Expected unscoped-explicit-empty-partition-lists-status-map summary to keep status counts aligned with explicit empty unscoped partition lists." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {"lint":"pass","typecheck":"fail"}' "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Expected unscoped-explicit-empty-partition-lists-status-map summary to preserve unscoped status-map metadata when partition lists are explicitly empty." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$unscoped_explicit_empty_partition_lists_status_map_step_summary" || ! grep -Fq "**Executed gates list:** lint, typecheck" "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Expected unscoped-explicit-empty-partition-lists-status-map summary to derive executed metadata from status-map evidence when partition lists are explicitly empty." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** none" "$unscoped_explicit_empty_partition_lists_status_map_step_summary" || ! grep -Fq "**Failed gates list:** none" "$unscoped_explicit_empty_partition_lists_status_map_step_summary" || ! grep -Fq "**Not-run gates list:** none" "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Expected unscoped-explicit-empty-partition-lists-status-map summary to preserve explicit empty unscoped partition list labels." >&2
	exit 1
fi
if ! grep -Fq "**Pass rate (executed gates):** 0%" "$unscoped_explicit_empty_partition_lists_status_map_step_summary" || ! grep -Fq "**Retry rate (executed gates):** 0%" "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Expected unscoped-explicit-empty-partition-lists-status-map summary to derive executed-rate metrics from explicit empty partition counts plus status-map executed fallback." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck" "$unscoped_explicit_empty_partition_lists_status_map_step_summary" || ! grep -Fq "**Attention gates list:** typecheck" "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Expected unscoped-explicit-empty-partition-lists-status-map summary to derive non-success/attention lists from unscoped status-map evidence." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_explicit_empty_partition_lists_status_map_step_summary"; then
	echo "Did not expect schema warning for unscoped-explicit-empty-partition-lists-status-map summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 2" "$unscoped_executed_fallback_empty_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-empty-status-map summary to derive gate count from sparse partition IDs." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$unscoped_executed_fallback_empty_status_map_step_summary" || ! grep -Fq "**Failed gates:** 1" "$unscoped_executed_fallback_empty_status_map_step_summary" || ! grep -Fq "**Executed gates:** 2" "$unscoped_executed_fallback_empty_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-empty-status-map summary to derive executed count from sparse partition fallback when status-map entries are absent." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates list:** typecheck, lint" "$unscoped_executed_fallback_empty_status_map_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_executed_fallback_empty_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-empty-status-map summary to derive executed list/pass rate from sparse partition fallback." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint" "$unscoped_executed_fallback_empty_status_map_step_summary" || ! grep -Fq "**Attention gates list:** lint" "$unscoped_executed_fallback_empty_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-empty-status-map summary to align non-success/attention lists with sparse failed partition evidence." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {}' "$unscoped_executed_fallback_empty_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-empty-status-map summary to preserve explicit empty status map metadata while deriving executed fallback from partitions." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_executed_fallback_empty_status_map_step_summary"; then
	echo "Did not expect schema warning for unscoped-executed-fallback-empty-status-map summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 2" "$unscoped_executed_explicit_empty_list_step_summary"; then
	echo "Expected unscoped-executed-explicit-empty-list summary to preserve sparse gate count metadata while explicit executed list is empty." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$unscoped_executed_explicit_empty_list_step_summary" || ! grep -Fq "**Failed gates:** 1" "$unscoped_executed_explicit_empty_list_step_summary"; then
	echo "Expected unscoped-executed-explicit-empty-list summary to preserve sparse partition counts when explicit executed list is empty." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 0" "$unscoped_executed_explicit_empty_list_step_summary" || ! grep -Fq "**Executed gates list:** none" "$unscoped_executed_explicit_empty_list_step_summary"; then
	echo "Expected unscoped-executed-explicit-empty-list summary to keep explicit empty executed list authoritative." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** n/a" "$unscoped_executed_explicit_empty_list_step_summary" || ! grep -Fq "**Retry backoff share (executed duration):** n/a" "$unscoped_executed_explicit_empty_list_step_summary" || ! grep -Fq "**Pass rate (executed gates):** n/a" "$unscoped_executed_explicit_empty_list_step_summary"; then
	echo "Expected unscoped-executed-explicit-empty-list summary to render executed-rate metrics as n/a for explicit empty executed list overrides." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** typecheck" "$unscoped_executed_explicit_empty_list_step_summary" || ! grep -Fq "**Retried gate count:** 1" "$unscoped_executed_explicit_empty_list_step_summary" || ! grep -Fq "**Total retries:** 2" "$unscoped_executed_explicit_empty_list_step_summary" || ! grep -Fq "**Total retry backoff:** 3s" "$unscoped_executed_explicit_empty_list_step_summary"; then
	echo "Expected unscoped-executed-explicit-empty-list summary to retain retry metadata while executed list override remains explicit and empty." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint" "$unscoped_executed_explicit_empty_list_step_summary" || ! grep -Fq "**Attention gates list:** typecheck, lint" "$unscoped_executed_explicit_empty_list_step_summary"; then
	echo "Expected unscoped-executed-explicit-empty-list summary to keep non-success/attention lists aligned with sparse fail and retried evidence under empty executed-list override." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_executed_explicit_empty_list_step_summary"; then
	echo "Did not expect schema warning for unscoped-executed-explicit-empty-list summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 2" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary"; then
	echo "Expected unscoped-executed-scalar-count-overrides-empty-list summary to preserve gate count from sparse status-map IDs." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 5" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary" || ! grep -Fq "**Executed gates list:** none" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary"; then
	echo "Expected unscoped-executed-scalar-count-overrides-empty-list summary to preserve explicit executedGateCount scalar over explicit empty executed list metadata." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary" || ! grep -Fq "**Failed gates:** 1" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary"; then
	echo "Expected unscoped-executed-scalar-count-overrides-empty-list summary to preserve sparse pass/fail counters while explicit executed scalar override is applied." >&2
	exit 1
fi
if ! grep -Fq "**Pass rate (executed gates):** 20%" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary" || ! grep -Fq "**Retry rate (executed gates):** 0%" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary"; then
	echo "Expected unscoped-executed-scalar-count-overrides-empty-list summary to derive rate metrics from explicit executedGateCount override and sparse pass/retry evidence." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** build" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary"; then
	echo "Expected unscoped-executed-scalar-count-overrides-empty-list summary to preserve non-success-derived attention metadata under explicit executed count override." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_executed_scalar_count_overrides_empty_list_step_summary"; then
	echo "Did not expect schema warning for unscoped-executed-scalar-count-overrides-empty-list summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 2" "$unscoped_executed_fallback_partial_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-partial-status-map summary to derive gate count from merged sparse status/partition IDs." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$unscoped_executed_fallback_partial_status_map_step_summary" || ! grep -Fq "**Failed gates:** 1" "$unscoped_executed_fallback_partial_status_map_step_summary" || ! grep -Fq "**Executed gates:** 2" "$unscoped_executed_fallback_partial_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-partial-status-map summary to derive executed count from merged sparse status-map and partition fallback data." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates list:** typecheck, lint" "$unscoped_executed_fallback_partial_status_map_step_summary" || ! grep -Fq "**Pass rate (executed gates):** 50%" "$unscoped_executed_fallback_partial_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-partial-status-map summary to derive executed list/pass-rate from merged sparse status-map and partition fallback data." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** lint" "$unscoped_executed_fallback_partial_status_map_step_summary" || ! grep -Fq "**Attention gates list:** lint" "$unscoped_executed_fallback_partial_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-partial-status-map summary to align non-success metadata with merged sparse status-map and partition fallback evidence." >&2
	exit 1
fi
if ! grep -Fq '**Gate status map:** {"typecheck":"pass"}' "$unscoped_executed_fallback_partial_status_map_step_summary"; then
	echo "Expected unscoped-executed-fallback-partial-status-map summary to preserve explicit partial unscoped status-map metadata." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$unscoped_executed_fallback_partial_status_map_step_summary"; then
	echo "Did not expect schema warning for unscoped-executed-fallback-partial-status-map summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 3" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive gate count from status map keys." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$derived_status_map_step_summary" || ! grep -Fq "**Failed gates:** 1" "$derived_status_map_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive counts from status map values." >&2
	exit 1
fi
if ! grep -Fq "**Status counts:** {\"pass\":1,\"fail\":1,\"skip\":0,\"not-run\":1}" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive statusCounts from normalized status map." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive selected gates from status map keys." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":\"pass\"" "$derived_status_map_step_summary" || ! grep -Fq "\"typecheck\":\"fail\"" "$derived_status_map_step_summary" || ! grep -Fq "\"build\":\"not-run\"" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize status-map keys and values." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":null" "$derived_status_map_step_summary" || ! grep -Fq "\"typecheck\":5" "$derived_status_map_step_summary" || ! grep -Fq "\"build\":null" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize gate exit-code map values and keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":2,\"typecheck\":0,\"build\":0}" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize retry-count map values and keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate duration map (s):** {\"lint\":1,\"typecheck\":2,\"build\":0}" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize duration map values and keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate attempt-count map:** {\"lint\":1,\"typecheck\":1,\"build\":0}" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize attempt-count map values and keys." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** typecheck" "$derived_status_map_step_summary" || ! grep -Fq "**Failed gate exit code:** 5" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive failed gate pointers from status/exit maps." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$derived_status_map_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$derived_status_map_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to infer fail-fast run-state metadata." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck, build" "$derived_status_map_step_summary" || ! grep -Fq "**Attention gates list:** lint, typecheck, build" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive non-success/attention lists from status map." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 2" "$derived_status_map_step_summary" || ! grep -Fq "**Total retry backoff:** 3s" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive retry totals from normalized retry map." >&2
	exit 1
fi
if ! grep -Fq "**Retry backoff share (executed duration):** 100%" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive retry-backoff share from normalized metrics." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 3s" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive total duration from duration map." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_status_map_step_summary"; then
	echo "Did not expect schema warning for derived-status-map fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 1" "$status_map_duplicate_keys_step_summary" || ! grep -Fq "**Failed gates:** 1" "$status_map_duplicate_keys_step_summary"; then
	echo "Expected status-map-duplicate-keys summary to resolve duplicate normalized map keys into one failed gate." >&2
	exit 1
fi
if ! grep -Fq "**Gate status map:** {\"lint\":\"fail\"}" "$status_map_duplicate_keys_step_summary"; then
	echo "Expected status-map-duplicate-keys summary to apply deterministic last-write behavior for duplicate normalized status-map keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate exit-code map:** {\"lint\":7}" "$status_map_duplicate_keys_step_summary"; then
	echo "Expected status-map-duplicate-keys summary to apply deterministic last-write behavior for duplicate normalized exit-code map keys." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$status_map_duplicate_keys_step_summary"; then
	echo "Did not expect schema warning for status-map-duplicate-keys summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":4}" "$duplicate_normalized_map_keys_step_summary"; then
	echo "Expected duplicate-normalized-map-keys summary to apply deterministic last-write behavior for duplicate normalized retry-count map keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate not-run reason map:** {\"lint\":\"second\"}" "$duplicate_normalized_map_keys_step_summary"; then
	echo "Expected duplicate-normalized-map-keys summary to apply deterministic last-write behavior for duplicate normalized reason map keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate duration map (s):** {\"lint\":6}" "$duplicate_normalized_map_keys_step_summary" || ! grep -Fq "**Gate attempt-count map:** {\"lint\":3}" "$duplicate_normalized_map_keys_step_summary"; then
	echo "Expected duplicate-normalized-map-keys summary to apply deterministic last-write behavior for duplicate normalized duration/attempt map keys." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 4" "$duplicate_normalized_map_keys_step_summary" || ! grep -Fq "**Total retry backoff:** 15s" "$duplicate_normalized_map_keys_step_summary"; then
	echo "Expected duplicate-normalized-map-keys summary to derive retry aggregates from normalized duplicate-map values." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 6s" "$duplicate_normalized_map_keys_step_summary" || ! grep -Fq "**Total duration:** 6s" "$duplicate_normalized_map_keys_step_summary"; then
	echo "Expected duplicate-normalized-map-keys summary to derive duration aggregates from normalized duplicate-map values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$duplicate_normalized_map_keys_step_summary"; then
	echo "Did not expect schema warning for duplicate-normalized-map-keys summary." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$derived_dry_run_step_summary"; then
	echo "Expected derived-dry-run fallback summary to infer success=true when dryRun=true and success is omitted." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** true" "$derived_dry_run_step_summary"; then
	echo "Expected derived-dry-run fallback summary to preserve dry-run flag." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** dry-run" "$derived_dry_run_step_summary"; then
	echo "Expected derived-dry-run fallback summary to derive dry-run exit reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** dry-run" "$derived_dry_run_step_summary"; then
	echo "Expected derived-dry-run fallback summary to derive dry-run classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_dry_run_step_summary"; then
	echo "Did not expect schema warning for derived-dry-run fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive success=false from failed gate evidence." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive continue-on-failure=true for completed failures." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** completed-with-failures" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive completed-with-failures exit reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-continued" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive failed-continued classification." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** lint" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive failed gate pointer from failedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit code:** 7" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive failed gate exit code from gateExitCodeById." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to keep blocked-by as none." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_continued_failure_step_summary"; then
	echo "Did not expect schema warning for derived-continued-failure summary." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$explicit_reason_step_summary"; then
	echo "Expected explicit-reason summary to derive success=false from exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$explicit_reason_step_summary"; then
	echo "Expected explicit-reason summary to ignore conflicting explicit continue-on-failure value and follow explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** completed-with-failures" "$explicit_reason_step_summary"; then
	echo "Expected explicit-reason summary to preserve explicit exit reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-continued" "$explicit_reason_step_summary"; then
	echo "Expected explicit-reason summary to derive failed-continued classification from explicit exit reason." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_reason_step_summary"; then
	echo "Did not expect schema warning for explicit-reason summary." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$invalid_reason_step_summary"; then
	echo "Expected invalid-reason summary to ignore unknown explicit exitReason and derive fail-fast reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$invalid_reason_step_summary"; then
	echo "Expected invalid-reason summary to derive failed-fail-fast classification from derived fail-fast reason." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** lint" "$invalid_reason_step_summary" || ! grep -Fq "**Failed gate exit code:** 9" "$invalid_reason_step_summary"; then
	echo "Expected invalid-reason summary to preserve failed gate pointers while deriving run-state." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invalid_reason_step_summary"; then
	echo "Did not expect schema warning for invalid-reason summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$explicit_run_classification_step_summary"; then
	echo "Expected explicit run-classification summary to derive success from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** success" "$explicit_run_classification_step_summary"; then
	echo "Expected explicit run-classification summary to derive exit reason from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-no-retries" "$explicit_run_classification_step_summary"; then
	echo "Expected explicit run-classification summary to normalize explicit runClassification value." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_run_classification_step_summary"; then
	echo "Did not expect schema warning for explicit run-classification summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$conflicting_reason_classification_step_summary"; then
	echo "Expected conflicting reason/classification summary to prioritize explicit exitReason for success inference." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$conflicting_reason_classification_step_summary"; then
	echo "Expected conflicting reason/classification summary to preserve explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$conflicting_reason_classification_step_summary"; then
	echo "Expected conflicting reason/classification summary to derive classification from explicit exitReason when explicit runClassification conflicts." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$conflicting_reason_classification_step_summary"; then
	echo "Did not expect schema warning for conflicting reason/classification summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to ignore conflicting explicit success value." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to ignore conflicting explicit dry-run value." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to ignore conflicting explicit continue-on-failure value." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to preserve explicit fail-fast reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to derive consistent failure classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$conflicting_run_state_flags_step_summary"; then
	echo "Did not expect schema warning for conflicting run-state flags summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to ignore conflicting explicit success value." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to ignore conflicting explicit dry-run value." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to ignore conflicting explicit continue-on-failure value." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** completed-with-failures" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to derive exit reason from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-continued" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to preserve explicit runClassification when internally consistent." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$conflicting_classification_flags_step_summary"; then
	echo "Did not expect schema warning for conflicting classification-flags summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$invalid_reason_with_classification_step_summary"; then
	echo "Expected invalid-reason-with-classification summary to derive success from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$invalid_reason_with_classification_step_summary"; then
	echo "Expected invalid-reason-with-classification summary to ignore unknown explicit exitReason and derive from runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$invalid_reason_with_classification_step_summary"; then
	echo "Expected invalid-reason-with-classification summary to normalize explicit runClassification value." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invalid_reason_with_classification_step_summary"; then
	echo "Did not expect schema warning for invalid-reason-with-classification summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$invalid_classification_with_reason_step_summary"; then
	echo "Expected invalid-classification-with-reason summary to derive success from explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$invalid_classification_with_reason_step_summary"; then
	echo "Expected invalid-classification-with-reason summary to derive continue-on-failure from explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** completed-with-failures" "$invalid_classification_with_reason_step_summary"; then
	echo "Expected invalid-classification-with-reason summary to preserve explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-continued" "$invalid_classification_with_reason_step_summary"; then
	echo "Expected invalid-classification-with-reason summary to ignore unknown explicit runClassification and derive from explicit exitReason." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invalid_classification_with_reason_step_summary"; then
	echo "Did not expect schema warning for invalid-classification-with-reason summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to derive success=true from explicit dry-run exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** true" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to derive dryRun=true from explicit dry-run exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to preserve explicit continue-on-failure configuration." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** dry-run" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to preserve explicit dry-run exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** dry-run" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to ignore conflicting explicit runClassification and derive dry-run classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$dry_run_reason_conflicts_step_summary"; then
	echo "Did not expect schema warning for dry-run-reason-conflicts summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to derive success=true from explicit success exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to ignore conflicting dry-run flag and derive dryRun=false for explicit success reason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to derive continue-on-failure=false for success runs when explicit value is absent." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** success" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to preserve explicit success exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-no-retries" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to ignore conflicting explicit runClassification and derive success classification from explicit exitReason." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$success_reason_conflicts_step_summary"; then
	echo "Did not expect schema warning for success-reason-conflicts summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$success_reason_explicit_continue_step_summary"; then
	echo "Expected success-reason-explicit-continue summary to preserve explicit success reason semantics." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$success_reason_explicit_continue_step_summary"; then
	echo "Expected success-reason-explicit-continue summary to preserve explicit continue-on-failure configuration." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-no-retries" "$success_reason_explicit_continue_step_summary"; then
	echo "Expected success-reason-explicit-continue summary to derive success classification despite conflicting explicit classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$success_reason_explicit_continue_step_summary"; then
	echo "Did not expect schema warning for success-reason-explicit-continue summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to ignore conflicting explicit success value and derive success=true from runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to ignore conflicting explicit dry-run value under success classification." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to preserve explicit continue-on-failure configuration for non-failure outcomes." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** success" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to derive success exit reason from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-with-retries" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to normalize explicit runClassification value." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$success_classification_explicit_continue_step_summary"; then
	echo "Did not expect schema warning for success-classification-explicit-continue summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to normalize numeric success=1 to true." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to normalize numeric dryRun=0 to false." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to normalize numeric continueOnFailure=0 to false." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** success" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to derive success exit reason from normalized numeric boolean values." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-no-retries" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to derive success-no-retries classification from normalized numeric boolean values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$numeric_boolean_flags_step_summary"; then
	echo "Did not expect schema warning for numeric-boolean-flags summary." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$invalid_numeric_boolean_flags_step_summary"; then
	echo "Expected invalid-numeric-boolean-flags summary to ignore unsupported numeric boolean values and derive success from explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$invalid_numeric_boolean_flags_step_summary"; then
	echo "Expected invalid-numeric-boolean-flags summary to ignore unsupported numeric dryRun value and derive false from explicit fail-fast reason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$invalid_numeric_boolean_flags_step_summary"; then
	echo "Expected invalid-numeric-boolean-flags summary to ignore unsupported numeric continue-on-failure value and derive false from explicit fail-fast reason." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$invalid_numeric_boolean_flags_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$invalid_numeric_boolean_flags_step_summary"; then
	echo "Expected invalid-numeric-boolean-flags summary to preserve explicit fail-fast reason semantics." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invalid_numeric_boolean_flags_step_summary"; then
	echo "Did not expect schema warning for invalid-numeric-boolean-flags summary." >&2
	exit 1
fi

node - "$retry_summary" "$future_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, futurePath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
payload.schemaVersion = 99;
fs.writeFileSync(futurePath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$future_step_summary" ./scripts/publish-verify-gates-summary.sh "$future_summary" "Verify Gates Future Schema Contract Test"

node - "$supported_schema_version" "$future_step_summary" <<'NODE'
const fs = require('node:fs');
const [supportedSchemaVersionRaw, futureStepPath] = process.argv.slice(2);
const supportedSchemaVersion = Number.parseInt(supportedSchemaVersionRaw, 10);
if (!Number.isInteger(supportedSchemaVersion) || supportedSchemaVersion <= 0) {
	throw new Error(`Invalid supported schema version: ${supportedSchemaVersionRaw}`);
}
const futureStep = fs.readFileSync(futureStepPath, 'utf8');
if (!futureStep.includes(`supported ${supportedSchemaVersion}`)) {
	throw new Error(`Future-schema warning should reference supported schema ${supportedSchemaVersion}.`);
}
const warningMatches = futureStep.match(/\*\*Schema warning:\*\*/g) ?? [];
if (warningMatches.length !== 1) {
	throw new Error('Future-schema output should contain exactly one schema warning line.');
}
NODE

node - "$retry_summary" "$future_string_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, futurePath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
payload.schemaVersion = ' 99 ';
fs.writeFileSync(futurePath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$future_string_step_summary" ./scripts/publish-verify-gates-summary.sh "$future_string_summary" "Verify Gates Future String Schema Contract Test"

node - "$supported_schema_version" "$future_string_step_summary" <<'NODE'
const fs = require('node:fs');
const [supportedSchemaVersionRaw, futureStepPath] = process.argv.slice(2);
const supportedSchemaVersion = Number.parseInt(supportedSchemaVersionRaw, 10);
if (!Number.isInteger(supportedSchemaVersion) || supportedSchemaVersion <= 0) {
	throw new Error(`Invalid supported schema version: ${supportedSchemaVersionRaw}`);
}
const futureStep = fs.readFileSync(futureStepPath, 'utf8');
if (!futureStep.includes('**Summary schema version:** 99')) {
	throw new Error('Future-string-schema output should normalize schema version string to integer.');
}
if (!futureStep.includes(`supported ${supportedSchemaVersion}`)) {
	throw new Error(`Future-string-schema warning should reference supported schema ${supportedSchemaVersion}.`);
}
const warningMatches = futureStep.match(/\*\*Schema warning:\*\*/g) ?? [];
if (warningMatches.length !== 1) {
	throw new Error('Future-string-schema output should contain exactly one schema warning line.');
}
NODE

node - "$retry_summary" "$invalid_schema_version_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, invalidPath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
payload.schemaVersion = 'v99';
fs.writeFileSync(invalidPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invalid_schema_version_step_summary" ./scripts/publish-verify-gates-summary.sh "$invalid_schema_version_summary" "Verify Gates Invalid Schema Version Contract Test"

if ! grep -Fq "**Summary schema version:** unknown" "$invalid_schema_version_step_summary"; then
	echo "Expected invalid-schema-version summary to normalize non-numeric schema versions to unknown." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invalid_schema_version_step_summary"; then
	echo "Did not expect schema warning for invalid non-numeric schema version metadata." >&2
	exit 1
fi

node - "$retry_summary" "$zero_schema_version_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, zeroPath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
payload.schemaVersion = 0;
fs.writeFileSync(zeroPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$zero_schema_version_step_summary" ./scripts/publish-verify-gates-summary.sh "$zero_schema_version_summary" "Verify Gates Zero Schema Version Contract Test"

if ! grep -Fq "**Summary schema version:** unknown" "$zero_schema_version_step_summary"; then
	echo "Expected zero-schema-version summary to treat non-positive schema versions as unknown." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$zero_schema_version_step_summary"; then
	echo "Did not expect schema warning for non-positive schema version metadata." >&2
	exit 1
fi

printf '{invalid json\n' > "$malformed_summary"
GITHUB_STEP_SUMMARY="$malformed_step_summary" ./scripts/publish-verify-gates-summary.sh "$malformed_summary" "Verify Gates Malformed Summary Contract Test"

node - "$malformed_step_summary" <<'NODE'
const fs = require('node:fs');
const [malformedStepPath] = process.argv.slice(2);
const malformedStep = fs.readFileSync(malformedStepPath, 'utf8');
if (!malformedStep.includes('Unable to parse verify-gates summary')) {
	throw new Error('Malformed-summary handling message missing from published step summary.');
}
if (!malformedStep.includes('malformed\\`name.json')) {
	throw new Error('Malformed-summary warning should include summary file path.');
}
NODE

set +e
./scripts/publish-verify-gates-summary.sh --unknown > "$tmpdir/unknown-option.out" 2>&1
unknown_option_status=$?
set -e
if [[ "$unknown_option_status" -eq 0 ]]; then
	echo "Expected publish-verify-gates-summary.sh --unknown to fail." >&2
	exit 1
fi
if ! grep -q "Unknown option" "$tmpdir/unknown-option.out"; then
	echo "Expected unknown-option output to include an explicit error message." >&2
	exit 1
fi
if ! grep -q "^Usage:" "$tmpdir/unknown-option.out"; then
	echo "Expected unknown-option output to include usage text." >&2
	exit 1
fi

set +e
GITHUB_STEP_SUMMARY="$missing_step_summary" ./scripts/publish-verify-gates-summary.sh "$tmpdir/does-not-exist.json" "Missing Summary File Test" > "$tmpdir/missing-summary.out" 2>&1
missing_summary_status=$?
set -e
if [[ "$missing_summary_status" -ne 0 ]]; then
	echo "Expected missing summary file path to be a no-op success." >&2
	exit 1
fi
if [[ -f "$missing_step_summary" ]]; then
	echo "Missing summary file should not create a step summary artifact." >&2
	exit 1
fi

set +e
GITHUB_STEP_SUMMARY="" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "Missing Step Summary Env Test" > "$tmpdir/missing-env.out" 2>&1
missing_env_status=$?
set -e
if [[ "$missing_env_status" -ne 0 ]]; then
	echo "Expected unset/empty GITHUB_STEP_SUMMARY handling to succeed." >&2
	exit 1
fi
if ! grep -q "GITHUB_STEP_SUMMARY is not set; skipping summary publication." "$tmpdir/missing-env.out"; then
	echo "Expected missing GITHUB_STEP_SUMMARY warning output." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --retries > "$tmpdir/missing-retries-value.out" 2>&1
missing_retries_value_status=$?
set -e
if [[ "$missing_retries_value_status" -eq 0 ]]; then
	echo "Expected --retries without a value to fail." >&2
	exit 1
fi
if ! grep -q "Missing value for --retries" "$tmpdir/missing-retries-value.out"; then
	echo "Expected missing --retries value message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --retries abc --dry-run > "$tmpdir/invalid-retries-alpha.out" 2>&1
invalid_retries_alpha_status=$?
set -e
if [[ "$invalid_retries_alpha_status" -eq 0 ]]; then
	echo "Expected non-numeric --retries value to fail." >&2
	exit 1
fi
if ! grep -q "Invalid retries value 'abc'" "$tmpdir/invalid-retries-alpha.out"; then
	echo "Expected non-numeric --retries validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --retries -1 --dry-run > "$tmpdir/invalid-retries-negative.out" 2>&1
invalid_retries_negative_status=$?
set -e
if [[ "$invalid_retries_negative_status" -eq 0 ]]; then
	echo "Expected negative --retries value to fail." >&2
	exit 1
fi
if ! grep -q "Invalid retries value '-1'" "$tmpdir/invalid-retries-negative.out"; then
	echo "Expected negative --retries validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --only lint,unknown --dry-run > "$tmpdir/unknown-gate.out" 2>&1
unknown_gate_status=$?
set -e
if [[ "$unknown_gate_status" -eq 0 ]]; then
	echo "Expected --only with unknown gate id to fail." >&2
	exit 1
fi
if ! grep -q "Unknown gate id 'unknown' for --only" "$tmpdir/unknown-gate.out"; then
	echo "Expected unknown gate id validation message." >&2
	exit 1
fi

set +e
VSCODE_VERIFY_CONTINUE_ON_FAILURE=maybe ./scripts/verify-gates.sh --quick --only lint --dry-run > "$tmpdir/invalid-continue-on-failure.out" 2>&1
invalid_continue_on_failure_status=$?
set -e
if [[ "$invalid_continue_on_failure_status" -eq 0 ]]; then
	echo "Expected invalid continue-on-failure environment value to fail." >&2
	exit 1
fi
if ! grep -q "Invalid continue-on-failure value 'maybe'" "$tmpdir/invalid-continue-on-failure.out"; then
	echo "Expected invalid continue-on-failure validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --from unknown --dry-run > "$tmpdir/unknown-from.out" 2>&1
unknown_from_status=$?
set -e
if [[ "$unknown_from_status" -eq 0 ]]; then
	echo "Expected --from unknown gate id to fail." >&2
	exit 1
fi
if ! grep -q "Unknown gate id 'unknown' for --from" "$tmpdir/unknown-from.out"; then
	echo "Expected unknown --from gate id validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --only " ,  " --dry-run > "$tmpdir/empty-only-list.out" 2>&1
empty_only_list_status=$?
set -e
if [[ "$empty_only_list_status" -eq 0 ]]; then
	echo "Expected --only with empty/whitespace gate list to fail." >&2
	exit 1
fi
if ! grep -q -- "--only produced an empty gate list" "$tmpdir/empty-only-list.out"; then
	echo "Expected empty --only list validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --from "   " --dry-run > "$tmpdir/empty-from-value.out" 2>&1
empty_from_value_status=$?
set -e
if [[ "$empty_from_value_status" -eq 0 ]]; then
	echo "Expected --from with whitespace value to fail." >&2
	exit 1
fi
if ! grep -q -- "--from requires a non-empty gate id." "$tmpdir/empty-from-value.out"; then
	echo "Expected empty --from value validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --help > "$tmpdir/verify-help.out" 2>&1
verify_help_status=$?
set -e
if [[ "$verify_help_status" -ne 0 ]]; then
	echo "Expected verify-gates.sh --help to succeed." >&2
	exit 1
fi
if ! grep -q "^Usage:" "$tmpdir/verify-help.out"; then
	echo "Expected verify-gates --help output to include usage text." >&2
	exit 1
fi
if ! grep -q "^Gate IDs:" "$tmpdir/verify-help.out"; then
	echo "Expected verify-gates --help output to include gate ID listing." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --not-a-real-option > "$tmpdir/verify-unknown-option.out" 2>&1
verify_unknown_option_status=$?
set -e
if [[ "$verify_unknown_option_status" -eq 0 ]]; then
	echo "Expected unknown verify-gates option to fail." >&2
	exit 1
fi
if ! grep -q "Unknown option: --not-a-real-option" "$tmpdir/verify-unknown-option.out"; then
	echo "Expected unknown verify-gates option validation message." >&2
	exit 1
fi
if ! grep -q "^Usage:" "$tmpdir/verify-unknown-option.out"; then
	echo "Expected unknown verify-gates option output to include usage text." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --summary-json > "$tmpdir/missing-summary-json-value.out" 2>&1
missing_summary_json_value_status=$?
set -e
if [[ "$missing_summary_json_value_status" -eq 0 ]]; then
	echo "Expected --summary-json without value to fail." >&2
	exit 1
fi
if ! grep -q "Missing value for --summary-json." "$tmpdir/missing-summary-json-value.out"; then
	echo "Expected missing --summary-json value message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --only > "$tmpdir/missing-only-value.out" 2>&1
missing_only_value_status=$?
set -e
if [[ "$missing_only_value_status" -eq 0 ]]; then
	echo "Expected --only without value to fail." >&2
	exit 1
fi
if ! grep -q "Missing value for --only." "$tmpdir/missing-only-value.out"; then
	echo "Expected missing --only value message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --from > "$tmpdir/missing-from-value.out" 2>&1
missing_from_value_status=$?
set -e
if [[ "$missing_from_value_status" -eq 0 ]]; then
	echo "Expected --from without value to fail." >&2
	exit 1
fi
if ! grep -q "Missing value for --from." "$tmpdir/missing-from-value.out"; then
	echo "Expected missing --from value message." >&2
	exit 1
fi

set +e
./scripts/publish-verify-gates-summary.sh --help > "$tmpdir/help.out" 2>&1
help_status=$?
set -e
if [[ "$help_status" -ne 0 ]]; then
	echo "Expected publish-verify-gates-summary.sh --help to succeed." >&2
	exit 1
fi
if ! grep -q "^Usage:" "$tmpdir/help.out"; then
	echo "Expected --help output to include usage text." >&2
	exit 1
fi
if ! grep -q "^GITHUB_STEP_SUMMARY" "$tmpdir/help.out"; then
	echo "Expected publisher --help output to include GITHUB_STEP_SUMMARY documentation." >&2
	exit 1
fi

node - "$expected_schema_version" "$minimal_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
fs.writeFileSync(summaryPath, JSON.stringify({ schemaVersion, success: true }, null, 2));
NODE

GITHUB_STEP_SUMMARY="$minimal_step_summary" ./scripts/publish-verify-gates-summary.sh "$minimal_summary" "Verify Gates Minimal Summary Contract Test"
if ! grep -q "| \`n/a\` | \`n/a\` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |" "$minimal_step_summary"; then
	echo "Expected minimal summary rendering to include placeholder gate row." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$minimal_step_summary"; then
	echo "Did not expect schema warning for minimal summary payload." >&2
	exit 1
fi

printf '%s\n' "$expected_schema_version" > "$scalar_summary"
GITHUB_STEP_SUMMARY="$scalar_step_summary" ./scripts/publish-verify-gates-summary.sh "$scalar_summary" "Verify Gates Scalar Summary Contract Test"
if ! grep -q "^## Verify Gates Scalar Summary Contract Test" "$scalar_step_summary"; then
	echo "Expected scalar summary heading to be rendered." >&2
	exit 1
fi
if ! grep -q "| \`n/a\` | \`n/a\` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |" "$scalar_step_summary"; then
	echo "Expected scalar summary rendering to include placeholder gate row." >&2
	exit 1
fi

printf '[]\n' > "$array_summary"
GITHUB_STEP_SUMMARY="$array_step_summary" ./scripts/publish-verify-gates-summary.sh "$array_summary" "Verify Gates Array Summary Contract Test"
if ! grep -q "^## Verify Gates Array Summary Contract Test" "$array_step_summary"; then
	echo "Expected array summary heading to be rendered." >&2
	exit 1
fi
if ! grep -q "| \`n/a\` | \`n/a\` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |" "$array_step_summary"; then
	echo "Expected array summary rendering to include placeholder gate row." >&2
	exit 1
fi
if ! grep -q "\*\*Summary schema version:\*\* unknown" "$array_step_summary"; then
	echo "Expected array summary rendering to use unknown schema placeholder." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$array_step_summary"; then
	echo "Did not expect schema warning for array summary payload." >&2
	exit 1
fi

printf 'null\n' > "$null_summary"
GITHUB_STEP_SUMMARY="$null_step_summary" ./scripts/publish-verify-gates-summary.sh "$null_summary" "Verify Gates Null Summary Contract Test"
if ! grep -q "^## Verify Gates Null Summary Contract Test" "$null_step_summary"; then
	echo "Expected null summary heading to be rendered." >&2
	exit 1
fi
if ! grep -q "| \`n/a\` | \`n/a\` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |" "$null_step_summary"; then
	echo "Expected null summary rendering to include placeholder gate row." >&2
	exit 1
fi
if ! grep -q "\*\*Summary schema version:\*\* unknown" "$null_step_summary"; then
	echo "Expected null summary rendering to use unknown schema placeholder." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$null_step_summary"; then
	echo "Did not expect schema warning for null summary payload." >&2
	exit 1
fi

set +e
VSCODE_VERIFY_SUMMARY_FILE="$retry_summary" GITHUB_STEP_SUMMARY="$env_path_step_summary" ./scripts/publish-verify-gates-summary.sh > "$tmpdir/env-path.out" 2>&1
env_path_status=$?
set -e
if [[ "$env_path_status" -ne 0 ]]; then
	echo "Expected publish script without args to succeed when VSCODE_VERIFY_SUMMARY_FILE is set." >&2
	exit 1
fi
if ! grep -q "^## Verify Gates Summary" "$env_path_step_summary"; then
	echo "Expected default heading when summary heading argument is omitted." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$env_path_step_summary"; then
	echo "Did not expect schema warning for current schema payload." >&2
	exit 1
fi

GITHUB_STEP_SUMMARY="$append_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "Append Heading One"
GITHUB_STEP_SUMMARY="$append_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "Append Heading Two"
if [[ "$(grep -c "^## Append Heading One$" "$append_step_summary")" -ne 1 ]]; then
	echo "Expected appended summary to include first heading exactly once." >&2
	exit 1
fi
if [[ "$(grep -c "^## Append Heading Two$" "$append_step_summary")" -ne 1 ]]; then
	echo "Expected appended summary to include second heading exactly once." >&2
	exit 1
fi
append_heading_one_line="$(grep -n "^## Append Heading One$" "$append_step_summary" | awk -F: 'NR==1 {print $1}')"
append_heading_two_line="$(grep -n "^## Append Heading Two$" "$append_step_summary" | awk -F: 'NR==1 {print $1}')"
if [[ -z "$append_heading_one_line" ]] || [[ -z "$append_heading_two_line" ]] || ((append_heading_one_line >= append_heading_two_line)); then
	echo "Expected appended headings to appear in write order." >&2
	exit 1
fi

GITHUB_STEP_SUMMARY="$multiline_heading_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" $'Multiline Heading\nSecond Line'
if ! grep -q "^## Multiline Heading Second Line$" "$multiline_heading_step_summary"; then
	echo "Expected multiline heading to be sanitized into a single heading line." >&2
	exit 1
fi

GITHUB_STEP_SUMMARY="$whitespace_heading_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" $'  Heading\twith   mixed\t whitespace  '
if ! grep -q "^## Heading with mixed whitespace$" "$whitespace_heading_step_summary"; then
	echo "Expected mixed-whitespace heading to normalize to single spaces." >&2
	exit 1
fi

GITHUB_STEP_SUMMARY="$blank_heading_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "   "
if ! grep -q "^## Verify Gates Summary$" "$blank_heading_step_summary"; then
	echo "Expected blank heading to fall back to default heading." >&2
	exit 1
fi

node - "$expected_schema_version" "$escape_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
const payload = {
	schemaVersion,
	success: true,
	gates: [
		{
			id: 'id|with`pipe',
			command: 'echo line1\r\nline2 | `',
			status: 'pass',
			attempts: 1,
			retryCount: 0,
			retryBackoffSeconds: 0,
			durationSeconds: 0,
			exitCode: 0,
			notRunReason: null,
		}
	]
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$escape_step_summary" ./scripts/publish-verify-gates-summary.sh "$escape_summary" "Verify Gates Escape Contract Test"

node - "$escape_step_summary" <<'NODE'
const fs = require('node:fs');
const [escapeStepPath] = process.argv.slice(2);
const escapeStep = fs.readFileSync(escapeStepPath, 'utf8');
if (!escapeStep.includes('id\\|with\\`pipe')) {
	throw new Error('Expected escaped gate id in markdown table output.');
}
if (!escapeStep.includes('line1 line2 \\| \\`')) {
	throw new Error('Expected escaped/single-line command in markdown table output.');
}
if (escapeStep.includes('\r')) {
	throw new Error('Expected carriage returns to be normalized from markdown output.');
}
NODE

node - "$expected_schema_version" "$code_span_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
const payload = {
	schemaVersion,
	success: true,
	logFile: 'path/with`tick\nline.log',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$code_span_step_summary" ./scripts/publish-verify-gates-summary.sh "$code_span_summary" "Verify Gates Code Span Contract Test"

node - "$code_span_step_summary" <<'NODE'
const fs = require('node:fs');
const [codeSpanStepPath] = process.argv.slice(2);
const codeSpanStep = fs.readFileSync(codeSpanStepPath, 'utf8');
if (!codeSpanStep.includes('**Log file:** `path/with\\`tick line.log`')) {
	throw new Error('Expected escaped/single-line log-file code span output.');
}
NODE

echo "verify-gates summary contract checks passed."
