FUNCTION z_egui_gem_req.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
  DATA lt_gem_resp TYPE STANDARD TABLE OF zegui_gem_resp WITH EMPTY KEY.
  DATA ls_gem_Resp TYPE zegui_gem_resp .

  SELECT * FROM zegui_purc_order INTO TABLE @DATA(lt_pos).

  SELECT COUNT(*) FROM zegui_gem_resp INTO @DATA(lv_gem).
  DATA(lo_gemini) = NEW zcl_egui_gemini_client( ).
  IF lv_gem = 0 .
    "maybe i will need to take out the loop from here and put it in the method,
    "issue may be about how fast does gemini reply to this and connections.



    LOOP AT lt_pos ASSIGNING FIELD-SYMBOL(<ls_po>).
       "should i mark in the db table or maybe isbetter to use a buffer but for now i will leave it in db table,
       "so if this conditions matches i will mark everythinsg as new
       "then it will be in the queue, after that i will call jobs and workers and also change the status as 'processing' to initialize one each or per chunks,
       "each po should have a different worker maybe (free trial will support it?)
       "then after recieving the response mark it as done
      DATA(lv_prompt) =
       |Summarize purchase order { <ls_po>-po_id } with status { <ls_po>-status },  delivery date { <ls_po>-deliverydate } , order date { <ls_po>-orderdate } and { <ls_po>-zztotalprice } |.
      DATA(lv_sumarry) = lo_gemini->summarize_order( iv_text = lv_prompt ).

      ls_gem_Resp-poid = <ls_po>-po_id.
      ls_gem_resp-summary = lv_sumarry.
      append ls_gem_resp to lt_gem_resp.
    ENDLOOP.

    insert zegui_gem_resp from table @( CORRESPONDING #( lt_gem_resp ) ).

  ENDIF.




ENDFUNCTION.
