CLASS zcl_test_zegui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test_zegui IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  delete from zegui_gem_resp where status = 'PROCESSING' ."is not initial.
  "update zegui_gem_resp set status = 'DONE' where poid = '0000000012'.
    data(lo_gemini) = new zcl_egui_gemini_client( ).
    "data(lv_response) = lo_gemini->summarize_order( iv_text = 'say hello' ).

    "out->write( lv_response ).
    out->write( 'HELLO' ).

  ENDMETHOD.
ENDCLASS.
