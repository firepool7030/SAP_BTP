CLASS lhc_MRP DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR mrp RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR mrp RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE mrp.

    METHODS valid_check FOR VALIDATE ON SAVE
      IMPORTING keys FOR mrp~valid_check.
    METHODS runmrplive FOR MODIFY
      IMPORTING keys FOR ACTION mrp~runmrplive RESULT result.

ENDCLASS.

CLASS lhc_MRP IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
  ENDMETHOD.

  METHOD valid_check.
  ENDMETHOD.

  METHOD RunMRPLive.
  ENDMETHOD.

ENDCLASS.
