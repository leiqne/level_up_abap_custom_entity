CLASS zcl_egui_gemini_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS summarize_order IMPORTING iv_text           TYPE string
                            RETURNING VALUE(rv_summary) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_egui_gemini_client IMPLEMENTATION.
  METHOD summarize_order.

    DATA: lo_http              TYPE REF TO if_web_http_client,
          lo_web_http_request  TYPE REF TO if_web_http_request,
          lo_web_http_response TYPE REF TO if_web_http_response.
    CONSTANTS lv_url TYPE string VALUE 'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=AIzaSyA7vsln9uL5_YHtKm_UBCXd00GUT17Yah8'.

    DATA(lv_body) = |\{ "contents": [\{ "parts": [\{ "text": "{ iv_text }" \}] \}] \}|.

    TRY.
        lo_http = cl_web_http_client_manager=>create_by_http_destination( cl_http_destination_provider=>create_by_url( lv_url ) ).

        lo_web_http_request = lo_http->get_http_request( ).

        lo_web_http_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_web_http_request->set_text( lv_body ).

        lo_web_http_response = lo_http->execute( if_web_http_client=>post ).

        DATA(lv_response_text)  = lo_web_http_response->get_text( ).

        "deserialize and get only text

        TYPES: BEGIN OF ty_part,
                 text TYPE string,
               END OF ty_part.

        TYPES: ty_parts TYPE STANDARD TABLE OF ty_part WITH EMPTY KEY.

        TYPES: BEGIN OF ty_content,
                 parts TYPE ty_parts,
               END OF ty_content.

        TYPES: BEGIN OF ty_candidate,
                 content TYPE ty_content,
               END OF ty_candidate.

        TYPES: ty_candidates TYPE STANDARD TABLE OF ty_candidate WITH EMPTY KEY.

        TYPES: BEGIN OF ty_response,
                 candidates TYPE ty_candidates,
               END OF ty_response.

        DATA ls_response TYPE ty_response.

        /ui2/cl_json=>deserialize(
          EXPORTING
            json = lv_response_text
          CHANGING
            data = ls_response
        ).

        READ TABLE ls_response-candidates INTO DATA(ls_candidate) INDEX 1.

        IF sy-subrc = 0.
          READ TABLE ls_candidate-content-parts INTO DATA(ls_part) INDEX 1.
          IF sy-subrc = 0.
            rv_summary = ls_part-text.
          ENDIF.
        ENDIF.

*        out->write( '--- Gemini ---' ).
*        out->write( lv_response_text ).
      CATCH cx_root INTO DATA(lx_error).
*    "some logic to manage errors
*    out->write( |Error: { lx_error->get_text( ) }| ).
    ENDTRY.

    IF lo_http IS BOUND.
      lo_http->close( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
