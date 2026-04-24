CLASS LHC_RAP_TDAT_CTS DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      GET
        RETURNING
           VALUE(RESULT) TYPE REF TO IF_MBC_CP_RAP_TABLE_CTS.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS IMPLEMENTATION.
*  METHOD GET.
*    result = mbc_cp_api=>rap_tdat_cts( tdat_name = 'ZTABLEFORUSERIDPASSW'
*                                       table_entity_relations = VALUE #(
*                                         ( entity = 'TableForUserIdPassw' table = 'ZUSER_ID' )
*                                       ) ) ##NO_TEXT.
*  ENDMETHOD.

 METHOD GET.
    result = mbc_cp_api=>rap_table_cts( table_entity_relations = VALUE #(
                                         ( entity = 'TableForUserIdPassw' table = 'ZUSER_ID' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.

ENDCLASS.
CLASS LHC_ZI_TABLEFORUSERIDPASSW_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR TableForUserIdPaAll
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION TableForUserIdPaAll~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR TableForUserIdPaAll
        RESULT result.
*      EDIT FOR MODIFY
*        IMPORTING
*          KEYS FOR ACTION TableForUserIdPaAll~edit.
ENDCLASS.

CLASS LHC_ZI_TABLEFORUSERIDPASSW_S IMPLEMENTATION.
*  METHOD GET_INSTANCE_FEATURES.
*    DATA: edit_flag            TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled
*         ,transport_feature    TYPE abp_behv_field_ctrl VALUE if_abap_behv=>fc-f-mandatory
*         ,selecttransport_flag TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled.
*
*    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
*      edit_flag = if_abap_behv=>fc-o-disabled.
*    ENDIF.
*    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
*      selecttransport_flag = if_abap_behv=>fc-o-disabled.
*    ENDIF.
*    IF lhc_rap_tdat_cts=>get( )->is_transport_mandatory( ) = abap_false.
*      transport_feature = if_abap_behv=>fc-f-unrestricted.
*    ENDIF.
*    IF keys[ 1 ]-%IS_DRAFT = if_abap_behv=>mk-off.
*      selecttransport_flag = if_abap_behv=>fc-o-disabled.
*    ENDIF.
*    result = VALUE #( (
*               %TKY = keys[ 1 ]-%TKY
*               %ACTION-edit = edit_flag
*               %ASSOC-_TableForUserIdPassw = edit_flag
*               %FIELD-TransportRequestID = transport_feature
*               %ACTION-SelectCustomizingTransptReq = selecttransport_flag ) ).
*  ENDMETHOD.



 METHOD GET_INSTANCE_FEATURES.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = 'ZUSER_ID'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = 'ZUSER_ID '
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF ZI_TABLEFORUSERIDPASSW_S  IN LOCAL MODE
    ENTITY TableForUserIdPaAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%IS_DRAFT = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %TKY = all[ 1 ]-%TKY
               %ACTION-edit = edit_flag
               %ASSOC-_TableForUserIdPassw = edit_flag
               %ACTION-SelectCustomizingTransptReq = selecttransport_flag ) ).
  ENDMETHOD.

 METHOD SELECTCUSTOMIZINGTRANSPTREQ.
    MODIFY ENTITIES OF ZI_TableForUserIdPassw_S IN LOCAL MODE
      ENTITY TableForUserIdPaAll
        UPDATE FIELDS ( TransportRequestID )
        WITH VALUE #( FOR key IN keys
                        ( %TKY               = key-%TKY
                          TransportRequestID = key-%PARAM-transportrequestid
                         ) ).

    READ ENTITIES OF ZI_TableForUserIdPassw_S IN LOCAL MODE
      ENTITY TableForUserIdPaAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %TKY   = entity-%TKY
                          %PARAM = entity ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_TABLEFORUSERIDPASSW' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%UPDATE      = is_authorized.
    result-%ACTION-Edit = is_authorized.
    result-%ACTION-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
*  METHOD EDIT.
*    CHECK lhc_rap_tdat_cts=>get( )->is_transport_mandatory( ).
*    DATA(transport_request) = lhc_rap_tdat_cts=>get( )->get_transport_request( ).
*    IF transport_request IS NOT INITIAL.
*      MODIFY ENTITY IN LOCAL MODE ZI_TableForUserIdPassw_S
*        EXECUTE SelectCustomizingTransptReq FROM VALUE #( ( %IS_DRAFT = if_abap_behv=>mk-on
*                                                            SingletonID = 1
*                                                            %PARAM-transportrequestid = transport_request ) ).
*      reported-TableForUserIdPaAll = VALUE #( ( %IS_DRAFT = if_abap_behv=>mk-on
*                                     SingletonID = 1
*                                     %MSG = mbc_cp_api=>message( )->get_transport_selected( transport_request ) ) ).
*    ENDIF.
*  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZI_TABLEFORUSERIDPASSW_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION,
      CLEANUP_FINALIZE REDEFINITION.
ENDCLASS.

CLASS LSC_ZI_TABLEFORUSERIDPASSW_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
    READ TABLE update-TableForUserIdPaAll INDEX 1 INTO DATA(all).
    IF all-TransportRequestID IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-TransportRequestID
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) )->update_last_changed_date_time( view_entity_name   = 'ZI_TABLEFORUSERIDPASSW'
                                                                                                        maintenance_object = 'ZTABLEFORUSERIDPASSW' ).
    ENDIF.
  ENDMETHOD.
  METHOD CLEANUP_FINALIZE ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_TABLEFORUSERIDPASSW DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
*    METHODS:
*      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
*        IMPORTING
*          REQUEST REQUESTED_FEATURES FOR TableForUserIdPassw
*        RESULT result,
*      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
*        IMPORTING
*          KEYS_TABLEFORUSERIDPASSW FOR TableForUserIdPassw~ValidateTransportRequest.

 METHODS:
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS FOR TableForUserIdPassw~ValidateTransportRequest,
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR TableForUserIdPassw
        RESULT result.

ENDCLASS.

CLASS LHC_ZI_TABLEFORUSERIDPASSW IMPLEMENTATION.
*  METHOD GET_GLOBAL_FEATURES.
*    DATA edit_flag TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.
*    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
*      edit_flag = if_abap_behv=>fc-o-disabled.
*    ENDIF.
*    result-%UPDATE = edit_flag.
*    result-%DELETE = edit_flag.
*  ENDMETHOD.

 METHOD GET_GLOBAL_FEATURES.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = 'ZUSER_ID'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
  ENDMETHOD.

*  METHOD VALIDATETRANSPORTREQUEST.
*    DATA change TYPE REQUEST FOR CHANGE ZI_TableForUserIdPassw_S.
*    IF keys_TableForUserIdPassw IS NOT INITIAL.
*      DATA(is_draft) = keys_TableForUserIdPassw[ 1 ]-%IS_DRAFT.
*    ELSE.
*      RETURN.
*    ENDIF.
*    READ ENTITY IN LOCAL MODE ZI_TableForUserIdPassw_S
*    FROM VALUE #( ( %IS_DRAFT = is_draft
*                    SingletonID = 1
*                    %CONTROL-TransportRequestID = if_abap_behv=>mk-on ) )
*    RESULT FINAL(transport_from_singleton).
*    lhc_rap_tdat_cts=>get( )->validate_all_changes(
*                                transport_request     = VALUE #( transport_from_singleton[ 1 ]-TransportRequestID OPTIONAL )
*                                table_validation_keys = VALUE #(
*                                                          ( table = 'ZUSER_ID' keys = REF #( keys_TableForUserIdPassw ) )
*                                                               )
*                                reported              = REF #( reported )
*                                failed                = REF #( failed )
*                                change                = REF #( change ) ).
*  ENDMETHOD.
*ENDCLASS.
 METHOD VALIDATETRANSPORTREQUEST.
    DATA change TYPE REQUEST FOR CHANGE ZI_TableForUserIdPassw_S.
    SELECT SINGLE TransportRequestID
      FROM zprod_sup_d_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = 'ZUSER_ID'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-TableForUserIdPassw ) ).
  ENDMETHOD.


ENDCLASS.
