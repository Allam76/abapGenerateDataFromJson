class ZCL_JSON_DATA_TO_DATA_REF definition
  public
  create public .

public section.
  class-methods convert importing json type string
                        returning value(return) type ref to data.
protected section.
  class-methods get_components importing json_data type  /ui5/cl_json_parser=>t_entry_map
                                         parent type string
                               returning value(result) type abap_component_tab.
  class-methods get_struct_type importing json_data type  /ui5/cl_json_parser=>t_entry_map
                                          item type /ui5/cl_json_parser=>t_entry
                                returning value(return) type ref to cl_abap_datadescr.
  class-methods get_single importing json_data type  /ui5/cl_json_parser=>t_entry_map
                           returning value(result) type  /ui5/cl_json_parser=>t_entry.
private section.
  CLASS-METHODS convert_name
    IMPORTING
      name TYPE string
    RETURNING
      value(result) TYPE string.
ENDCLASS.



CLASS ZCL_JSON_DATA_TO_DATA_REF IMPLEMENTATION.
 method convert.
   data(parser) = new /ui5/cl_json_parser( ).
   parser->parse( json = json ).

   data(handle) = get_struct_type( json_data = parser->m_entries item = parser->m_entries[ name = '' ] ).
   create data return type handle handle.
   assign return->* to field-symbol(<return>).

   /ui2/cl_json=>deserialize( exporting json = json changing data = <return> ).
 endmethod.

 method get_components.
   result = value abap_component_tab( for item in json_data where ( parent = parent and name <> '' ) (
    NAME = convert_name( ITEM-NAME )
    type = get_struct_type( item = item json_data = json_data ) ) ).
 endmethod.

 method get_struct_type.
   if item-name <> '' and not line_exists( json_data[ parent = item-parent && '/' && item-name ] ) and item-type <> 1.
    return = cast cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( 'string' ) ).
   else.
       return = switch #( item-type
           when 1 then cast cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( 'string' ) )
           when 2 then cast cl_abap_datadescr( cl_abap_structdescr=>create(
             p_components = get_components( json_data = json_data parent = cond #( when item-name = '' then '' else item-parent && '/' && item-name ) ) )
          )
          when 3 then cast cl_abap_datadescr( cl_abap_tabledescr=>create( p_line_type = get_struct_type(
            json_data = json_data
            item = cond #( when item-name = '' then get_single( json_data = json_data ) else json_data[ parent = item-parent && '/' && item-name ] ) )
          ) )
        ).
   endif.
 endmethod.

  METHOD convert_name.
    result = name.
    replace all occurrences of ` ` in result with '_'.
    replace all occurrences of `.` in result with '_'.
    replace all occurrences of `?` in result with '_'.
  ENDMETHOD.

  method get_single.
    data(temp) = json_data.
    delete temp where parent <> '' or name = ''.
    read table temp into result index 1.
  endmethod.

ENDCLASS.
