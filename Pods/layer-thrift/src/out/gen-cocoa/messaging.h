/**
 * Autogenerated by Thrift Compiler (0.9.1)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */

#import <Foundation/Foundation.h>

#import "TProtocol.h"
#import "TApplicationException.h"
#import "TProtocolException.h"
#import "TProtocolUtil.h"
#import "TProcessor.h"
#import "TObjective-C.h"
#import "TBase.h"


enum LYRTErrorCode {
  ErrorCode_UNSPECIFIED_ERROR = 1,
  ErrorCode_STREAM_SEQ_CONTENTION = 2
};

enum LYRTEventType {
  EventType_APPLICATION = 1,
  EventType_MEMBER_ADDED = 2,
  EventType_MEMBER_REMOVED = 3,
  EventType_MESSAGE = 4,
  EventType_MESSAGE_DELIVERED = 5,
  EventType_MESSAGE_READ = 6,
  EventType_METADATA_ADDED = 7,
  EventType_METADATA_REMOVED = 8
};

typedef NSData * LYRTUUID;

typedef NSString * LYRTProviderUserId;

@interface LYRTError : NSObject <TBase, NSCoding> {
  int __code;
  NSString * __message;

  BOOL __code_isset;
  BOOL __message_isset;
}

#if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
@property (nonatomic, getter=code, setter=setCode:) int code;
@property (nonatomic, retain, getter=message, setter=setMessage:) NSString * message;
#endif

- (id) init;
- (id) initWithCode: (int) code message: (NSString *) message;

- (void) read: (id <TProtocol>) inProtocol;
- (void) write: (id <TProtocol>) outProtocol;

- (void) validate;

#if !__has_feature(objc_arc)
- (int) code;
- (void) setCode: (int) code;
#endif
- (BOOL) codeIsSet;

#if !__has_feature(objc_arc)
- (NSString *) message;
- (void) setMessage: (NSString *) message;
#endif
- (BOOL) messageIsSet;

@end

@interface LYRTEvent : NSObject <TBase, NSCoding> {
  int __type;
  LYRTProviderUserId __creator_id;
  int32_t __seq;
  int64_t __timestamp;
  int32_t __preceding_seq;
  int32_t __client_seq;
  uint8_t __subtype;
  NSMutableDictionary * __metadata;
  NSMutableArray * __content_types;
  NSMutableArray * __inline_content_parts;
  LYRTUUID __external_content_id;
  LYRTProviderUserId __member_id;
  int32_t __target_seq;

  BOOL __type_isset;
  BOOL __creator_id_isset;
  BOOL __seq_isset;
  BOOL __timestamp_isset;
  BOOL __preceding_seq_isset;
  BOOL __client_seq_isset;
  BOOL __subtype_isset;
  BOOL __metadata_isset;
  BOOL __content_types_isset;
  BOOL __inline_content_parts_isset;
  BOOL __external_content_id_isset;
  BOOL __member_id_isset;
  BOOL __target_seq_isset;
}

#if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
@property (nonatomic, getter=type, setter=setType:) int type;
@property (nonatomic, retain, getter=creator_id, setter=setCreator_id:) LYRTProviderUserId creator_id;
@property (nonatomic, getter=seq, setter=setSeq:) int32_t seq;
@property (nonatomic, getter=timestamp, setter=setTimestamp:) int64_t timestamp;
@property (nonatomic, getter=preceding_seq, setter=setPreceding_seq:) int32_t preceding_seq;
@property (nonatomic, getter=client_seq, setter=setClient_seq:) int32_t client_seq;
@property (nonatomic, getter=subtype, setter=setSubtype:) uint8_t subtype;
@property (nonatomic, retain, getter=metadata, setter=setMetadata:) NSMutableDictionary * metadata;
@property (nonatomic, retain, getter=content_types, setter=setContent_types:) NSMutableArray * content_types;
@property (nonatomic, retain, getter=inline_content_parts, setter=setInline_content_parts:) NSMutableArray * inline_content_parts;
@property (nonatomic, retain, getter=external_content_id, setter=setExternal_content_id:) LYRTUUID external_content_id;
@property (nonatomic, retain, getter=member_id, setter=setMember_id:) LYRTProviderUserId member_id;
@property (nonatomic, getter=target_seq, setter=setTarget_seq:) int32_t target_seq;
#endif

- (id) init;
- (id) initWithType: (int) type creator_id: (LYRTProviderUserId) creator_id seq: (int32_t) seq timestamp: (int64_t) timestamp preceding_seq: (int32_t) preceding_seq client_seq: (int32_t) client_seq subtype: (uint8_t) subtype metadata: (NSMutableDictionary *) metadata content_types: (NSMutableArray *) content_types inline_content_parts: (NSMutableArray *) inline_content_parts external_content_id: (LYRTUUID) external_content_id member_id: (LYRTProviderUserId) member_id target_seq: (int32_t) target_seq;

- (void) read: (id <TProtocol>) inProtocol;
- (void) write: (id <TProtocol>) outProtocol;

- (void) validate;

#if !__has_feature(objc_arc)
- (int) type;
- (void) setType: (int) type;
#endif
- (BOOL) typeIsSet;

#if !__has_feature(objc_arc)
- (LYRTProviderUserId) creator_id;
- (void) setCreator_id: (LYRTProviderUserId) creator_id;
#endif
- (BOOL) creator_idIsSet;

#if !__has_feature(objc_arc)
- (int32_t) seq;
- (void) setSeq: (int32_t) seq;
#endif
- (BOOL) seqIsSet;

#if !__has_feature(objc_arc)
- (int64_t) timestamp;
- (void) setTimestamp: (int64_t) timestamp;
#endif
- (BOOL) timestampIsSet;

#if !__has_feature(objc_arc)
- (int32_t) preceding_seq;
- (void) setPreceding_seq: (int32_t) preceding_seq;
#endif
- (BOOL) preceding_seqIsSet;

#if !__has_feature(objc_arc)
- (int32_t) client_seq;
- (void) setClient_seq: (int32_t) client_seq;
#endif
- (BOOL) client_seqIsSet;

#if !__has_feature(objc_arc)
- (uint8_t) subtype;
- (void) setSubtype: (uint8_t) subtype;
#endif
- (BOOL) subtypeIsSet;

#if !__has_feature(objc_arc)
- (NSMutableDictionary *) metadata;
- (void) setMetadata: (NSMutableDictionary *) metadata;
#endif
- (BOOL) metadataIsSet;

#if !__has_feature(objc_arc)
- (NSMutableArray *) content_types;
- (void) setContent_types: (NSMutableArray *) content_types;
#endif
- (BOOL) content_typesIsSet;

#if !__has_feature(objc_arc)
- (NSMutableArray *) inline_content_parts;
- (void) setInline_content_parts: (NSMutableArray *) inline_content_parts;
#endif
- (BOOL) inline_content_partsIsSet;

#if !__has_feature(objc_arc)
- (LYRTUUID) external_content_id;
- (void) setExternal_content_id: (LYRTUUID) external_content_id;
#endif
- (BOOL) external_content_idIsSet;

#if !__has_feature(objc_arc)
- (LYRTProviderUserId) member_id;
- (void) setMember_id: (LYRTProviderUserId) member_id;
#endif
- (BOOL) member_idIsSet;

#if !__has_feature(objc_arc)
- (int32_t) target_seq;
- (void) setTarget_seq: (int32_t) target_seq;
#endif
- (BOOL) target_seqIsSet;

@end

@interface LYRTStream : NSObject <TBase, NSCoding> {
  LYRTUUID __stream_id;
  NSMutableSet * __member_ids;
  int32_t __seq;

  BOOL __stream_id_isset;
  BOOL __member_ids_isset;
  BOOL __seq_isset;
}

#if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
@property (nonatomic, retain, getter=stream_id, setter=setStream_id:) LYRTUUID stream_id;
@property (nonatomic, retain, getter=member_ids, setter=setMember_ids:) NSMutableSet * member_ids;
@property (nonatomic, getter=seq, setter=setSeq:) int32_t seq;
#endif

- (id) init;
- (id) initWithStream_id: (LYRTUUID) stream_id member_ids: (NSMutableSet *) member_ids seq: (int32_t) seq;

- (void) read: (id <TProtocol>) inProtocol;
- (void) write: (id <TProtocol>) outProtocol;

- (void) validate;

#if !__has_feature(objc_arc)
- (LYRTUUID) stream_id;
- (void) setStream_id: (LYRTUUID) stream_id;
#endif
- (BOOL) stream_idIsSet;

#if !__has_feature(objc_arc)
- (NSMutableSet *) member_ids;
- (void) setMember_ids: (NSMutableSet *) member_ids;
#endif
- (BOOL) member_idsIsSet;

#if !__has_feature(objc_arc)
- (int32_t) seq;
- (void) setSeq: (int32_t) seq;
#endif
- (BOOL) seqIsSet;

@end

@interface LYRTResponse : NSObject <TBase, NSCoding> {
  LYRTError * __error;
  LYRTEvent * __event;
  int32_t __seq;
  LYRTStream * __stream;
  NSMutableSet * __streams;

  BOOL __error_isset;
  BOOL __event_isset;
  BOOL __seq_isset;
  BOOL __stream_isset;
  BOOL __streams_isset;
}

#if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
@property (nonatomic, retain, getter=error, setter=setError:) LYRTError * error;
@property (nonatomic, retain, getter=event, setter=setEvent:) LYRTEvent * event;
@property (nonatomic, getter=seq, setter=setSeq:) int32_t seq;
@property (nonatomic, retain, getter=stream, setter=setStream:) LYRTStream * stream;
@property (nonatomic, retain, getter=streams, setter=setStreams:) NSMutableSet * streams;
#endif

- (id) init;
- (id) initWithError: (LYRTError *) error event: (LYRTEvent *) event seq: (int32_t) seq stream: (LYRTStream *) stream streams: (NSMutableSet *) streams;

- (void) read: (id <TProtocol>) inProtocol;
- (void) write: (id <TProtocol>) outProtocol;

- (void) validate;

#if !__has_feature(objc_arc)
- (LYRTError *) error;
- (void) setError: (LYRTError *) error;
#endif
- (BOOL) errorIsSet;

#if !__has_feature(objc_arc)
- (LYRTEvent *) event;
- (void) setEvent: (LYRTEvent *) event;
#endif
- (BOOL) eventIsSet;

#if !__has_feature(objc_arc)
- (int32_t) seq;
- (void) setSeq: (int32_t) seq;
#endif
- (BOOL) seqIsSet;

#if !__has_feature(objc_arc)
- (LYRTStream *) stream;
- (void) setStream: (LYRTStream *) stream;
#endif
- (BOOL) streamIsSet;

#if !__has_feature(objc_arc)
- (NSMutableSet *) streams;
- (void) setStreams: (NSMutableSet *) streams;
#endif
- (BOOL) streamsIsSet;

@end

@interface LYRTmessagingConstants : NSObject {
}
+ (int32_t) VERSION;
@end
