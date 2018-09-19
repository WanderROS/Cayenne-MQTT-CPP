#Makefile for building Linux C++ example and test executables

SRC_DIR := src
PLATFORM_DIR := $(SRC_DIR)/Platform/Linux
EXAMPLES_DIR := $(PLATFORM_DIR)/examples
TESTS_DIR := $(PLATFORM_DIR)/tests
BUILD_DIR := build
TEST_BUILD_DIR := $(BUILD_DIR)/test
CC := gcc
COMMON_INCLUDE_DIRS := -I$(SRC_DIR)/MQTTCommon -I$(PLATFORM_DIR)
CFLAGS := -Wall -Wstrict-prototypes -O2 -MMD -MP $(COMMON_INCLUDE_DIRS)
CXXFLAGS := -Wall -O2 -MMD -MP $(COMMON_INCLUDE_DIRS) -I$(SRC_DIR)/CayenneMQTTClient

#Paths containing source files
vpath %c $(SRC_DIR)/CayenneUtils:$(SRC_DIR)/MQTTCommon:$(EXAMPLES_DIR):$(TESTS_DIR)
vpath %cpp $(SRC_DIR)/CayenneMQTTClient:$(SRC_DIR)/CayenneUtils:$(SRC_DIR)/MQTTCommon:$(EXAMPLES_DIR):$(TESTS_DIR)

COMMON_SOURCES := $(notdir $(SRC_DIR)/CayenneUtils/CayenneUtils.c $(wildcard $(SRC_DIR)/MQTTCommon/*.c))
COMMON_OBJS := $(COMMON_SOURCES:.c=.o)
NETWORK_OBJS := Network.o

#Ojbects and dependency files for examples
SIMPLE_PUBLISH_OBJS := $(addprefix $(BUILD_DIR)/, $(COMMON_OBJS) SimplePublish.o)
SIMPLE_SUBSCRIBE_OBJS := $(addprefix $(BUILD_DIR)/, $(COMMON_OBJS) SimpleSubscribe.o)
CLIENT_EXAMPLE_OBJS := $(addprefix $(BUILD_DIR)/, $(COMMON_OBJS) CayenneClient.o)

#Ojbects and dependency files for tests
TEST_CLIENT_OBJS := $(addprefix $(TEST_BUILD_DIR)/, $(COMMON_OBJS) TestClient.o)

.PHONY: all examples test clean

all: examples test

examples: simplepub simplesub cayenneclient

test: testclient

simplepub: $(SIMPLE_PUBLISH_OBJS)
	$(CC) $(CXXFLAGS) $^ -o $@
    
simplesub: $(SIMPLE_SUBSCRIBE_OBJS)
	$(CC) $(CXXFLAGS) $^ -o $@
	
cayenneclient: $(CLIENT_EXAMPLE_OBJS)
	$(CC) $(CXXFLAGS) $^ -o $@

testclient: $(TEST_CLIENT_OBJS)
	$(CC) $(CXXFLAGS) $^ -o $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<	

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) -c -o $@ $<

$(TEST_BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -DPARSE_INFO_PAYLOADS -c -o $@ $<	

$(TEST_BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) -DPARSE_INFO_PAYLOADS -c -o $@ $<
	
clean:
	rm -r -f $(BUILD_DIR)
	rm -f simplepub simplesub cayenneclient testclient

-include $(BUILD_DIR)/*.d 
