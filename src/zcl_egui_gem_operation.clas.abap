
CLASS zcl_egui_gem_operation DEFINITION public final create PUBLIC.

  PUBLIC SECTION.
    METHODS constructor IMPORTING iv_poid TYPE zegui_id.
    "INTERFACES if_abap_parallel.
    INTERFACES if_bgmc_op_single_tx_uncontr.
    INTERFACES if_serializable_object.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: lv_poid TYPE zegui_id.
    "methods do.
    "methods run.

ENDCLASS.

CLASS zcl_egui_gem_operation IMPLEMENTATION.

  METHOD constructor.
    lv_poid = iv_poid.
  ENDMETHOD.

  METHOD if_bgmc_op_single_tx_uncontr~execute.
    SELECT SINGLE * FROM zegui_purc_order WHERE po_id = @me->lv_poid INTO @DATA(ls_po).
    "create a worker or a job before
    "parallel execution
    TRY.
        DATA(lo_gemini) = NEW zcl_egui_gemini_client( ).
        DATA(lv_prompt) = |Summarize purchase order { ls_po-po_id } with status { ls_po-status },  delivery date { ls_po-deliverydate } , order date { ls_po-orderdate } and { ls_po-zztotalprice } |.
        DATA(lv_summary) = lo_gemini->summarize_order( iv_text = lv_prompt ).
        if lv_summary is not iniTIAL.
        "why is not waiting?
        UPDATE zegui_gem_resp SET status = 'DONE', summary = @lv_summary  WHERE poid = @me->lv_poid.
        else .
            UPDATE zegui_gem_resp SET status = 'ERROR'  WHERE poid = @me->lv_poid.
        endif.

        commit work.
      CATCH cx_root INTO DATA(lv_error).
        "do something with error.
        UPDATE zegui_gem_resp
          SET status = 'ERROR'
          WHERE poid = @me->lv_poid.
          commit work.
    ENDTRY.
    get time stamp field data(lv_timestamp).
      update zegui_purc_order set last_changed_at = @lv_timestamp where po_id = @me->lv_poid.
      commit work.
  ENDMETHOD.

ENDCLASS.
