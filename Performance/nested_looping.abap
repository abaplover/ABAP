*&---------------------------------------------------------------------*
*& Report  ZNESTED_LOOPING
*&
*&---------------------------------------------------------------------*
*& ABAP Sample Code
*& Performance in nested looping
*&
*& Mauricio Lauffer
*& http://www.linkedin.com/in/mauriciolauffer
*&
*& This sample explains how to use nested looping with performance
*&
*&---------------------------------------------------------------------*

REPORT znested_looping.


DATA:
  gt_bkpf TYPE STANDARD TABLE OF bkpf,
  gt_bseg TYPE STANDARD TABLE OF bseg.

FIELD-SYMBOLS:
  <gs_bkpf> TYPE bkpf,
  <gs_bseg> TYPE bseg.


"Select header
SELECT * UP TO 500 ROWS
  FROM bkpf
  INTO TABLE gt_bkpf.
IF sy-subrc <> 0.
  RETURN.
ENDIF.

"Select items
SELECT *
  FROM bseg
  INTO TABLE gt_bseg
  FOR ALL ENTRIES IN gt_bkpf
  WHERE bukrs = gt_bkpf-bukrs
    AND belnr = gt_bkpf-belnr
    AND gjahr = gt_bkpf-gjahr.

"Looping into header
LOOP AT gt_bkpf ASSIGNING <gs_bkpf>.
  "Get index (sy-tabix) for the first occurrence
  "You must guarantee that the table is sorted by the keys used in BINARY SEARCH
  READ TABLE gt_bseg TRANSPORTING NO FIELDS
       WITH KEY bukrs = <gs_bkpf>-bukrs
                belnr = <gs_bkpf>-belnr
                gjahr = <gs_bkpf>-gjahr
       BINARY SEARCH.
  CHECK sy-subrc = 0.

  "Looping into items from index which we got before
  LOOP AT gt_bseg ASSIGNING <gs_bseg> FROM sy-tabix.
    "Check the table key, if it has changed, leave this looping
    IF <gs_bkpf>-bukrs <> <gs_bseg>-bukrs
       OR <gs_bkpf>-belnr <> <gs_bseg>-belnr
       OR <gs_bkpf>-gjahr <> <gs_bseg>-gjahr.
      EXIT.
    ENDIF.

    "Do stuff...
  ENDLOOP.
ENDLOOP.