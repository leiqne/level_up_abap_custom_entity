CLASS zcl_egui_po_query_gemini DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_purc,
             poid TYPE zegui_id,
           END OF ty_purc.
    TYPES ty_purc_table TYPE STANDARD TABLE OF ty_purc WITH EMPTY KEY.

    METHODS get_non_summ_pos RETURNING VALUE(rt_po) TYPE ty_purc_table.
    METHODS assign_workers IMPORTING it_po TYPE ty_purc_table.

ENDCLASS.

CLASS zcl_egui_po_query_gemini IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    DATA(lo_paging)   = io_request->get_paging( ).
    DATA(lv_offset)   = lo_paging->get_offset( ).
    DATA(lv_page_size) = lo_paging->get_page_size( ).

    "async process
    DATA(lt_pending) = get_non_summ_pos( ).
    IF lt_pending IS NOT INITIAL.
      assign_workers( lt_pending ).
    ENDIF.

    SELECT * FROM zegui_purc_order INTO TABLE @DATA(lt_pos).
    SELECT * FROM zegui_gem_resp   INTO TABLE @DATA(lt_summ).

    DATA lt_data TYPE STANDARD TABLE OF zegui_ce_purchaseorder WITH EMPTY KEY.

    LOOP AT lt_pos ASSIGNING FIELD-SYMBOL(<ls_po>).
      ASSIGN lt_summ[ poid = <ls_po>-po_id ] TO FIELD-SYMBOL(<ls_summ>).
      APPEND VALUE #(
        poid          = <ls_po>-po_id
        deliverydate  = <ls_po>-deliverydate
        orderdate     = <ls_po>-orderdate
        buyerid       = <ls_po>-buyer_id
        status        = <ls_po>-status
        last_changed_at = <ls_po>-last_changed_at
        currencycode  = <ls_po>-currencycode
        totalprice    = <ls_po>-zztotalprice
        sumarry       = COND #( WHEN <ls_summ> IS ASSIGNED AND <ls_summ>-summary is not initial
                                THEN <ls_summ>-summary ELSE 'waiting...' )
      ) TO lt_data.
    ENDLOOP.

    io_response->set_data( lt_data ).
    io_response->set_total_number_of_records( lines( lt_data ) ).


  ENDMETHOD.

  METHOD get_non_summ_pos.
    SELECT po~po_id FROM zegui_purc_order AS po
      LEFT OUTER JOIN zegui_gem_resp AS gem
        ON po~po_id = gem~poid
      WHERE gem~poid IS NULL OR gem~status = 'ERROR'
      into table @rt_po
      "limited because of free tier xd
      up to 5 rows.
*      loop at lt_po assigning field-SYMBOL(<ls_po>) .
*        if <ls_po>-po_id is initial or <ls_po>-summary is initial or <ls_po>-status <> 'DONE'.
*        append <ls_po>-po_id to rt_po.
*        ENDIF.
*      endloop.
      "INTO TABLE @rt_po.
  ENDMETHOD.

  METHOD assign_workers.
    LOOP AT it_po ASSIGNING FIELD-SYMBOL(<ls_po>).

      UPDATE zegui_gem_resp SET status = 'PROCESSING' WHERE poid = @<ls_po>-poid.
      IF sy-subrc <> 0.
        INSERT zegui_gem_resp FROM @( VALUE #(
            poid   = <ls_po>-poid
            status = 'PROCESSING'
        ) ).
      ENDIF.

      TRY.
          cl_bgmc_process_factory=>get_default(
          )->create(
          )->set_operation_tx_uncontrolled( NEW zcl_egui_gem_operation( <ls_po>-poid )
          )->save_for_execution( ).
        CATCH cx_bgmc.
      ENDTRY.

    ENDLOOP.
    COMMIT WORK.
  ENDMETHOD.

ENDCLASS.
