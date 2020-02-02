add_contract(exchange-deposits exchange-deposits ${CMAKE_CURRENT_SOURCE_DIR}/src/exchange-deposits.cpp)

target_include_directories(exchange-deposits
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(exchange-deposits
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/exchange-deposits.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/exchange-deposits.contracts.md @ONLY )

target_compile_options( exchange-deposits PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )
