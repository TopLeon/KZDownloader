// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_task.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDownloadTaskCollection on Isar {
  IsarCollection<DownloadTask> get downloadTasks => this.collection();
}

const DownloadTaskSchema = CollectionSchema(
  name: r'DownloadTask',
  id: -8326932930248620171,
  properties: {
    r'activeWorkers': PropertySchema(
      id: 0,
      name: r'activeWorkers',
      type: IsarType.long,
    ),
    r'cachedDescription': PropertySchema(
      id: 1,
      name: r'cachedDescription',
      type: IsarType.string,
    ),
    r'cachedTranscript': PropertySchema(
      id: 2,
      name: r'cachedTranscript',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 3,
      name: r'category',
      type: IsarType.byte,
      enumMap: _DownloadTaskcategoryEnumValueMap,
    ),
    r'channelId': PropertySchema(
      id: 4,
      name: r'channelId',
      type: IsarType.string,
    ),
    r'channelName': PropertySchema(
      id: 5,
      name: r'channelName',
      type: IsarType.string,
    ),
    r'completedAt': PropertySchema(
      id: 6,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completedSteps': PropertySchema(
      id: 7,
      name: r'completedSteps',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 8,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dirPath': PropertySchema(
      id: 9,
      name: r'dirPath',
      type: IsarType.string,
    ),
    r'downloadSpeed': PropertySchema(
      id: 10,
      name: r'downloadSpeed',
      type: IsarType.string,
    ),
    r'errorMessage': PropertySchema(
      id: 11,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'eta': PropertySchema(
      id: 12,
      name: r'eta',
      type: IsarType.string,
    ),
    r'filePath': PropertySchema(
      id: 13,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'isPlaylistContainer': PropertySchema(
      id: 14,
      name: r'isPlaylistContainer',
      type: IsarType.bool,
    ),
    r'playlistCompletedVideos': PropertySchema(
      id: 15,
      name: r'playlistCompletedVideos',
      type: IsarType.long,
    ),
    r'playlistId': PropertySchema(
      id: 16,
      name: r'playlistId',
      type: IsarType.string,
    ),
    r'playlistParentId': PropertySchema(
      id: 17,
      name: r'playlistParentId',
      type: IsarType.long,
    ),
    r'playlistTotalVideos': PropertySchema(
      id: 18,
      name: r'playlistTotalVideos',
      type: IsarType.long,
    ),
    r'processTime': PropertySchema(
      id: 19,
      name: r'processTime',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 20,
      name: r'progress',
      type: IsarType.double,
    ),
    r'provider': PropertySchema(
      id: 21,
      name: r'provider',
      type: IsarType.string,
    ),
    r'qaHistory': PropertySchema(
      id: 22,
      name: r'qaHistory',
      type: IsarType.objectList,
      target: r'QAItem',
    ),
    r'startedAt': PropertySchema(
      id: 23,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 24,
      name: r'status',
      type: IsarType.string,
    ),
    r'stepDetailsJson': PropertySchema(
      id: 25,
      name: r'stepDetailsJson',
      type: IsarType.string,
    ),
    r'summary': PropertySchema(
      id: 26,
      name: r'summary',
      type: IsarType.string,
    ),
    r'summaryType': PropertySchema(
      id: 27,
      name: r'summaryType',
      type: IsarType.string,
    ),
    r'thumbnail': PropertySchema(
      id: 28,
      name: r'thumbnail',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 29,
      name: r'title',
      type: IsarType.string,
    ),
    r'totalSize': PropertySchema(
      id: 30,
      name: r'totalSize',
      type: IsarType.string,
    ),
    r'totalWorkers': PropertySchema(
      id: 31,
      name: r'totalWorkers',
      type: IsarType.long,
    ),
    r'url': PropertySchema(
      id: 32,
      name: r'url',
      type: IsarType.string,
    ),
    r'workersProgressJson': PropertySchema(
      id: 33,
      name: r'workersProgressJson',
      type: IsarType.string,
    )
  },
  estimateSize: _downloadTaskEstimateSize,
  serialize: _downloadTaskSerialize,
  deserialize: _downloadTaskDeserialize,
  deserializeProp: _downloadTaskDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'QAItem': QAItemSchema},
  getId: _downloadTaskGetId,
  getLinks: _downloadTaskGetLinks,
  attach: _downloadTaskAttach,
  version: '3.3.0',
);

int _downloadTaskEstimateSize(
  DownloadTask object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cachedDescription;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cachedTranscript;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.channelId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.channelName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.completedSteps.length * 3;
  {
    for (var i = 0; i < object.completedSteps.length; i++) {
      final value = object.completedSteps[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.dirPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.downloadSpeed;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.eta;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.filePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.playlistId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.processTime;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.provider.length * 3;
  {
    final list = object.qaHistory;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[QAItem]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += QAItemSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.stepDetailsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.summary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.summaryType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.thumbnail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.totalSize;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.url.length * 3;
  {
    final value = object.workersProgressJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _downloadTaskSerialize(
  DownloadTask object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activeWorkers);
  writer.writeString(offsets[1], object.cachedDescription);
  writer.writeString(offsets[2], object.cachedTranscript);
  writer.writeByte(offsets[3], object.category.index);
  writer.writeString(offsets[4], object.channelId);
  writer.writeString(offsets[5], object.channelName);
  writer.writeDateTime(offsets[6], object.completedAt);
  writer.writeStringList(offsets[7], object.completedSteps);
  writer.writeDateTime(offsets[8], object.createdAt);
  writer.writeString(offsets[9], object.dirPath);
  writer.writeString(offsets[10], object.downloadSpeed);
  writer.writeString(offsets[11], object.errorMessage);
  writer.writeString(offsets[12], object.eta);
  writer.writeString(offsets[13], object.filePath);
  writer.writeBool(offsets[14], object.isPlaylistContainer);
  writer.writeLong(offsets[15], object.playlistCompletedVideos);
  writer.writeString(offsets[16], object.playlistId);
  writer.writeLong(offsets[17], object.playlistParentId);
  writer.writeLong(offsets[18], object.playlistTotalVideos);
  writer.writeString(offsets[19], object.processTime);
  writer.writeDouble(offsets[20], object.progress);
  writer.writeString(offsets[21], object.provider);
  writer.writeObjectList<QAItem>(
    offsets[22],
    allOffsets,
    QAItemSchema.serialize,
    object.qaHistory,
  );
  writer.writeDateTime(offsets[23], object.startedAt);
  writer.writeString(offsets[24], object.status);
  writer.writeString(offsets[25], object.stepDetailsJson);
  writer.writeString(offsets[26], object.summary);
  writer.writeString(offsets[27], object.summaryType);
  writer.writeString(offsets[28], object.thumbnail);
  writer.writeString(offsets[29], object.title);
  writer.writeString(offsets[30], object.totalSize);
  writer.writeLong(offsets[31], object.totalWorkers);
  writer.writeString(offsets[32], object.url);
  writer.writeString(offsets[33], object.workersProgressJson);
}

DownloadTask _downloadTaskDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DownloadTask();
  object.activeWorkers = reader.readLongOrNull(offsets[0]);
  object.cachedDescription = reader.readStringOrNull(offsets[1]);
  object.cachedTranscript = reader.readStringOrNull(offsets[2]);
  object.category =
      _DownloadTaskcategoryValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          TaskCategory.video;
  object.channelId = reader.readStringOrNull(offsets[4]);
  object.channelName = reader.readStringOrNull(offsets[5]);
  object.completedAt = reader.readDateTimeOrNull(offsets[6]);
  object.completedSteps = reader.readStringList(offsets[7]) ?? [];
  object.createdAt = reader.readDateTime(offsets[8]);
  object.dirPath = reader.readStringOrNull(offsets[9]);
  object.downloadSpeed = reader.readStringOrNull(offsets[10]);
  object.errorMessage = reader.readStringOrNull(offsets[11]);
  object.eta = reader.readStringOrNull(offsets[12]);
  object.filePath = reader.readStringOrNull(offsets[13]);
  object.id = id;
  object.isPlaylistContainer = reader.readBool(offsets[14]);
  object.playlistCompletedVideos = reader.readLongOrNull(offsets[15]);
  object.playlistId = reader.readStringOrNull(offsets[16]);
  object.playlistParentId = reader.readLongOrNull(offsets[17]);
  object.playlistTotalVideos = reader.readLongOrNull(offsets[18]);
  object.processTime = reader.readStringOrNull(offsets[19]);
  object.progress = reader.readDouble(offsets[20]);
  object.provider = reader.readString(offsets[21]);
  object.qaHistory = reader.readObjectList<QAItem>(
    offsets[22],
    QAItemSchema.deserialize,
    allOffsets,
    QAItem(),
  );
  object.startedAt = reader.readDateTimeOrNull(offsets[23]);
  object.status = reader.readString(offsets[24]);
  object.stepDetailsJson = reader.readStringOrNull(offsets[25]);
  object.summary = reader.readStringOrNull(offsets[26]);
  object.summaryType = reader.readStringOrNull(offsets[27]);
  object.thumbnail = reader.readStringOrNull(offsets[28]);
  object.title = reader.readStringOrNull(offsets[29]);
  object.totalSize = reader.readStringOrNull(offsets[30]);
  object.totalWorkers = reader.readLongOrNull(offsets[31]);
  object.url = reader.readString(offsets[32]);
  object.workersProgressJson = reader.readStringOrNull(offsets[33]);
  return object;
}

P _downloadTaskDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (_DownloadTaskcategoryValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TaskCategory.video) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readDouble(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readObjectList<QAItem>(
        offset,
        QAItemSchema.deserialize,
        allOffsets,
        QAItem(),
      )) as P;
    case 23:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readLongOrNull(offset)) as P;
    case 32:
      return (reader.readString(offset)) as P;
    case 33:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DownloadTaskcategoryEnumValueMap = {
  'video': 0,
  'music': 1,
  'generic': 2,
  'summary': 3,
  'home': 4,
  'inprogress': 5,
  'failed': 6,
  'settings': 7,
  'playlist': 8,
};
const _DownloadTaskcategoryValueEnumMap = {
  0: TaskCategory.video,
  1: TaskCategory.music,
  2: TaskCategory.generic,
  3: TaskCategory.summary,
  4: TaskCategory.home,
  5: TaskCategory.inprogress,
  6: TaskCategory.failed,
  7: TaskCategory.settings,
  8: TaskCategory.playlist,
};

Id _downloadTaskGetId(DownloadTask object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _downloadTaskGetLinks(DownloadTask object) {
  return [];
}

void _downloadTaskAttach(
    IsarCollection<dynamic> col, Id id, DownloadTask object) {
  object.id = id;
}

extension DownloadTaskQueryWhereSort
    on QueryBuilder<DownloadTask, DownloadTask, QWhere> {
  QueryBuilder<DownloadTask, DownloadTask, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DownloadTaskQueryWhere
    on QueryBuilder<DownloadTask, DownloadTask, QWhereClause> {
  QueryBuilder<DownloadTask, DownloadTask, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DownloadTaskQueryFilter
    on QueryBuilder<DownloadTask, DownloadTask, QFilterCondition> {
  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      activeWorkersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activeWorkers',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      activeWorkersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activeWorkers',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      activeWorkersEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeWorkers',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      activeWorkersGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeWorkers',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      activeWorkersLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeWorkers',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      activeWorkersBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeWorkers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cachedDescription',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cachedDescription',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cachedDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cachedDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cachedDescription',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cachedDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cachedDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cachedDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cachedDescription',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedDescriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cachedDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cachedTranscript',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cachedTranscript',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cachedTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cachedTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cachedTranscript',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cachedTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cachedTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cachedTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cachedTranscript',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedTranscript',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      cachedTranscriptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cachedTranscript',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      categoryEqualTo(TaskCategory value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      categoryGreaterThan(
    TaskCategory value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      categoryLessThan(
    TaskCategory value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      categoryBetween(
    TaskCategory lower,
    TaskCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'channelId',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'channelId',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'channelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'channelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'channelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'channelId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'channelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'channelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'channelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'channelId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'channelId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'channelId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'channelName',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'channelName',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'channelName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'channelName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'channelName',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      channelNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'channelName',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedSteps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedSteps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedSteps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedSteps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completedSteps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completedSteps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completedSteps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completedSteps',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedSteps',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completedSteps',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedSteps',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedSteps',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedSteps',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedSteps',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedSteps',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      completedStepsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedSteps',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dirPath',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dirPath',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dirPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dirPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dirPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dirPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dirPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dirPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dirPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dirPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dirPath',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      dirPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dirPath',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'downloadSpeed',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'downloadSpeed',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadSpeed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'downloadSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'downloadSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'downloadSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'downloadSpeed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadSpeed',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      downloadSpeedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'downloadSpeed',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eta',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      etaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eta',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      etaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> etaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eta',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      etaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eta',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'filePath',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'filePath',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      isPlaylistContainerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPlaylistContainer',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistCompletedVideosIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playlistCompletedVideos',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistCompletedVideosIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playlistCompletedVideos',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistCompletedVideosEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistCompletedVideos',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistCompletedVideosGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistCompletedVideos',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistCompletedVideosLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistCompletedVideos',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistCompletedVideosBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistCompletedVideos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playlistId',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playlistId',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playlistId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playlistId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistParentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playlistParentId',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistParentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playlistParentId',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistParentIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistParentId',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistParentIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistParentId',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistParentIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistParentId',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistParentIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistParentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistTotalVideosIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playlistTotalVideos',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistTotalVideosIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playlistTotalVideos',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistTotalVideosEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistTotalVideos',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistTotalVideosGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistTotalVideos',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistTotalVideosLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistTotalVideos',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      playlistTotalVideosBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistTotalVideos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'processTime',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'processTime',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'processTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'processTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'processTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'processTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processTime',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      processTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'processTime',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      progressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      progressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      progressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      progressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'provider',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'provider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provider',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      providerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'provider',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'qaHistory',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'qaHistory',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'qaHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'qaHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'qaHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'qaHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'qaHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'qaHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      startedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startedAt',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      startedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startedAt',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      startedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      startedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      startedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stepDetailsJson',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stepDetailsJson',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stepDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stepDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stepDetailsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stepDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stepDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stepDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stepDetailsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepDetailsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      stepDetailsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stepDetailsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'summary',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'summary',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'summaryType',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'summaryType',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summaryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summaryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summaryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summaryType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summaryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summaryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summaryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summaryType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summaryType',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      summaryTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summaryType',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnail',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnail',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnail',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      thumbnailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnail',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalSize',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalSize',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'totalSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'totalSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'totalSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'totalSize',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSize',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalSizeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'totalSize',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalWorkersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalWorkers',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalWorkersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalWorkers',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalWorkersEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalWorkers',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalWorkersGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalWorkers',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalWorkersLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalWorkers',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      totalWorkersBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalWorkers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'workersProgressJson',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'workersProgressJson',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workersProgressJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workersProgressJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workersProgressJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workersProgressJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'workersProgressJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'workersProgressJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'workersProgressJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'workersProgressJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workersProgressJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      workersProgressJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'workersProgressJson',
        value: '',
      ));
    });
  }
}

extension DownloadTaskQueryObject
    on QueryBuilder<DownloadTask, DownloadTask, QFilterCondition> {
  QueryBuilder<DownloadTask, DownloadTask, QAfterFilterCondition>
      qaHistoryElement(FilterQuery<QAItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'qaHistory');
    });
  }
}

extension DownloadTaskQueryLinks
    on QueryBuilder<DownloadTask, DownloadTask, QFilterCondition> {}

extension DownloadTaskQuerySortBy
    on QueryBuilder<DownloadTask, DownloadTask, QSortBy> {
  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByActiveWorkers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeWorkers', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByActiveWorkersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeWorkers', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByCachedDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedDescription', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByCachedDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedDescription', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByCachedTranscript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedTranscript', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByCachedTranscriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedTranscript', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByChannelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelId', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByChannelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelId', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByChannelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelName', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByChannelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelName', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByDirPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dirPath', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByDirPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dirPath', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByDownloadSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadSpeed', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByDownloadSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadSpeed', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByEta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eta', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByEtaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eta', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByIsPlaylistContainer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlaylistContainer', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByIsPlaylistContainerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlaylistContainer', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByPlaylistCompletedVideos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistCompletedVideos', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByPlaylistCompletedVideosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistCompletedVideos', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByPlaylistParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistParentId', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByPlaylistParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistParentId', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByPlaylistTotalVideos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistTotalVideos', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByPlaylistTotalVideosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistTotalVideos', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByProcessTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processTime', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByProcessTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processTime', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByStepDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepDetailsJson', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByStepDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepDetailsJson', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortBySummaryType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryType', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortBySummaryTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryType', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByThumbnailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByTotalSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSize', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByTotalSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSize', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByTotalWorkers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkers', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByTotalWorkersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkers', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByWorkersProgressJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workersProgressJson', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      sortByWorkersProgressJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workersProgressJson', Sort.desc);
    });
  }
}

extension DownloadTaskQuerySortThenBy
    on QueryBuilder<DownloadTask, DownloadTask, QSortThenBy> {
  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByActiveWorkers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeWorkers', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByActiveWorkersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeWorkers', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByCachedDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedDescription', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByCachedDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedDescription', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByCachedTranscript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedTranscript', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByCachedTranscriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedTranscript', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByChannelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelId', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByChannelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelId', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByChannelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelName', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByChannelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelName', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByDirPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dirPath', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByDirPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dirPath', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByDownloadSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadSpeed', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByDownloadSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadSpeed', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByEta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eta', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByEtaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eta', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByIsPlaylistContainer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlaylistContainer', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByIsPlaylistContainerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlaylistContainer', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByPlaylistCompletedVideos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistCompletedVideos', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByPlaylistCompletedVideosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistCompletedVideos', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByPlaylistParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistParentId', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByPlaylistParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistParentId', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByPlaylistTotalVideos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistTotalVideos', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByPlaylistTotalVideosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistTotalVideos', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByProcessTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processTime', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByProcessTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processTime', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByStepDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepDetailsJson', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByStepDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepDetailsJson', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenBySummaryType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryType', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenBySummaryTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryType', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByThumbnailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByTotalSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSize', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByTotalSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSize', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByTotalWorkers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkers', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByTotalWorkersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkers', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByWorkersProgressJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workersProgressJson', Sort.asc);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QAfterSortBy>
      thenByWorkersProgressJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workersProgressJson', Sort.desc);
    });
  }
}

extension DownloadTaskQueryWhereDistinct
    on QueryBuilder<DownloadTask, DownloadTask, QDistinct> {
  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByActiveWorkers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeWorkers');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByCachedDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedDescription',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByCachedTranscript({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedTranscript',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByChannelId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'channelId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByChannelName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'channelName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByCompletedSteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedSteps');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByDirPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dirPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByDownloadSpeed(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadSpeed',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByErrorMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByEta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eta', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByIsPlaylistContainer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPlaylistContainer');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByPlaylistCompletedVideos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistCompletedVideos');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByPlaylistId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByPlaylistParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistParentId');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByPlaylistTotalVideos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistTotalVideos');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByProcessTime(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByProvider(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'provider', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByStepDetailsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepDetailsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctBySummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctBySummaryType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summaryType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByThumbnail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByTotalSize(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSize', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByTotalWorkers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalWorkers');
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTask, DownloadTask, QDistinct>
      distinctByWorkersProgressJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workersProgressJson',
          caseSensitive: caseSensitive);
    });
  }
}

extension DownloadTaskQueryProperty
    on QueryBuilder<DownloadTask, DownloadTask, QQueryProperty> {
  QueryBuilder<DownloadTask, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DownloadTask, int?, QQueryOperations> activeWorkersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeWorkers');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations>
      cachedDescriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedDescription');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations>
      cachedTranscriptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedTranscript');
    });
  }

  QueryBuilder<DownloadTask, TaskCategory, QQueryOperations>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> channelIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'channelId');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> channelNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'channelName');
    });
  }

  QueryBuilder<DownloadTask, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<DownloadTask, List<String>, QQueryOperations>
      completedStepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedSteps');
    });
  }

  QueryBuilder<DownloadTask, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> dirPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dirPath');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations>
      downloadSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadSpeed');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> etaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eta');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<DownloadTask, bool, QQueryOperations>
      isPlaylistContainerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPlaylistContainer');
    });
  }

  QueryBuilder<DownloadTask, int?, QQueryOperations>
      playlistCompletedVideosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistCompletedVideos');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> playlistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistId');
    });
  }

  QueryBuilder<DownloadTask, int?, QQueryOperations>
      playlistParentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistParentId');
    });
  }

  QueryBuilder<DownloadTask, int?, QQueryOperations>
      playlistTotalVideosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistTotalVideos');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> processTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processTime');
    });
  }

  QueryBuilder<DownloadTask, double, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<DownloadTask, String, QQueryOperations> providerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'provider');
    });
  }

  QueryBuilder<DownloadTask, List<QAItem>?, QQueryOperations>
      qaHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qaHistory');
    });
  }

  QueryBuilder<DownloadTask, DateTime?, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<DownloadTask, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations>
      stepDetailsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepDetailsJson');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summary');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> summaryTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summaryType');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> thumbnailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnail');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations> totalSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSize');
    });
  }

  QueryBuilder<DownloadTask, int?, QQueryOperations> totalWorkersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalWorkers');
    });
  }

  QueryBuilder<DownloadTask, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<DownloadTask, String?, QQueryOperations>
      workersProgressJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workersProgressJson');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const QAItemSchema = Schema(
  name: r'QAItem',
  id: 4244676762724025897,
  properties: {
    r'answer': PropertySchema(
      id: 0,
      name: r'answer',
      type: IsarType.string,
    ),
    r'question': PropertySchema(
      id: 1,
      name: r'question',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _qAItemEstimateSize,
  serialize: _qAItemSerialize,
  deserialize: _qAItemDeserialize,
  deserializeProp: _qAItemDeserializeProp,
);

int _qAItemEstimateSize(
  QAItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.answer;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.question;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _qAItemSerialize(
  QAItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.answer);
  writer.writeString(offsets[1], object.question);
  writer.writeDateTime(offsets[2], object.timestamp);
}

QAItem _qAItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QAItem();
  object.answer = reader.readStringOrNull(offsets[0]);
  object.question = reader.readStringOrNull(offsets[1]);
  object.timestamp = reader.readDateTimeOrNull(offsets[2]);
  return object;
}

P _qAItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension QAItemQueryFilter on QueryBuilder<QAItem, QAItem, QFilterCondition> {
  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'answer',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'answer',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'answer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'answer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answer',
        value: '',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> answerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'answer',
        value: '',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'question',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'question',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'question',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'question',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> questionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> timestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> timestampEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> timestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> timestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<QAItem, QAItem, QAfterFilterCondition> timestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension QAItemQueryObject on QueryBuilder<QAItem, QAItem, QFilterCondition> {}
