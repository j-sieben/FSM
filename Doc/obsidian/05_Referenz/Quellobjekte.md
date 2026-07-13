# Quellobjekte

## Laufzeitkern

- `FSM/core/types/fsm_type.tps` – abstrakter Vertrag und Hooks
- `FSM/core/types/fsm_type.tpb` – Delegation an das Package `FSM`
- `FSM/core/packages/fsm.pks` – öffentliche Laufzeit-API
- `FSM/core/packages/fsm.pkb` – Ablaufsteuerung und private Hilfsmethoden

## Administration

- `FSM/core/packages/fsm_admin.pks`
- `FSM/core/packages/fsm_admin.pkb`
- `FSM/core/scripts/utl_text_templates_FSM.sql`

## Metadaten und Laufzeitdaten

- `FSM/core/tables`
- `FSM/core/views`
- `FSM/core/scripts/initial_data.sql`

## Beispielimplementierung

- `FSM/sample_app/sequences/fsm_request_seq.seq`
- `FSM/sample_app/tables/fsm_requests.tbl`
- `FSM/sample_app/views/fsm_requests_vw.vw`
- `FSM/sample_app/types/fsm_req_type.tps`
- `FSM/sample_app/types/fsm_req_type.tpb`
- `FSM/sample_app/packages/fsm_req.pks`
- `FSM/sample_app/packages/fsm_req.pkb`
- `FSM/sample_app/packages/bl_request.pks`
- `FSM/sample_app/packages/bl_request.pkb`
- `FSM/sample_app/scripts/create_fsm_data.sql`

## Generierte Referenz

Die Natural-Docs-Startseite liegt unter `Doc/index.html`. `Doc/Overview.md` und `Doc/How_it_works.md` bieten ergänzende Überblickstexte; dieser Vault beschreibt den Lifecycle zusammenhängend.
