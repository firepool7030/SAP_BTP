CLASS lhc_PIRHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PIRHeader RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR PIRHeader RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE PIRHeader.

    METHODS earlynumbering_cba_Piri FOR NUMBERING
      IMPORTING entities FOR CREATE PIRHeader\_Piri.

ENDCLASS.

CLASS lhc_PIRHeader IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
  ENDMETHOD.

  METHOD earlynumbering_cba_Piri.
  ENDMETHOD.

ENDCLASS.
