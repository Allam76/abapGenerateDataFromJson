class test definition for testing risk level harmless.
  public section.
    methods simple_test for testing.
    methods test_empty_object for testing.
    methods config_test for testing.
endclass.

class test implementation.
 method simple_test.
  data(ref) = zcl_json_data_to_data_ref=>convert( json = '{"aa":"aa","bb":{"cc":{"dd":"dd"},"ee":"ee"},"ff":["fa","fb"]}' ).
 endmethod.

 method test_empty_object.
   data(ref) = zcl_json_data_to_data_ref=>convert( json = '{"aa":{}}' ).
 endmethod.

 method config_test.
   types: begin of config,
            expr type string,
            dataset type string,
            bindings type string,
            result type string,
          end of config.
  data(source) = `{"expr": "$substring(\"hello world\", -5, 5)","dataset": "dataset5","bindings": {},"result": "world"}`.
  data res type config.
  /ui2/cl_json=>deserialize( exporting json = source  changing data = res ).
 endmethod.
endclass.
