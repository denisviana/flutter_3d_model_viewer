/* This is free and unencumbered software released into the public domain. */

import 'dart:typed_data'
    show ByteData, Endian, Float32List, Float64List, Int16List, Int32List, Int64List, Uint8List;

import 'package:typed_data/typed_buffers.dart' show Uint8Buffer;

import 'bundle.dart' show Bundle;
import 'parcelable.dart' show Parcelable;

const int valNull = -1;
const int valString = 0;
const int valInteger = 1;
const int valMap = 2;
const int valBundle = 3;
const int valParcelable = 4;
const int valShort = 5;
const int valLong = 6;
const int valFloat = 7;
const int valDouble = 8;
const int valBoolean = 9;
const int valCharsequence = 10;
const int valList = 11;
const int valSparseArray = 12;
const int valByteArray = 13;
const int valStringArray = 14;
const int valIBinder = 15;
const int valParcelableArray = 16;
const int valObjectArray = 17;
const int valIntArray = 18;
const int valLongArray = 19;
const int valByte = 20;
const int valSerializable = 21;
const int valSparseBooleanArray = 22;
const int valBooleanArray = 23;
const int valCharsequenceArray = 24;
const int valPersistableBundle = 25;
const int valSize = 26;
const int valSizeF = 27;
const int valDoubleArray = 28;

/// Container for a message (data and object references) that can be sent
/// through an `IBinder`.
///
/// See: https://developer.android.com/reference/android/os/Parcel
class Parcel {
  /// See: https://developer.android.com/reference/android/os/Parcel#STRING_CREATOR
  //static const Parcelable.Creator<String> STRING_CREATOR = null; // TODO

  final Uint8Buffer _output = Uint8Buffer();
  final ByteData _buffer = ByteData(8);
  Uint8List? _bufferAsList;

  Parcel.obtain() {
    _bufferAsList = _buffer.buffer.asUint8List();
  }

  void writeValue(final Object? val) {
    if (val == null) {
      writeInt(valNull);
    } else if (val is String) {
      writeInt(valString);
      writeString(val);
    } else if (val is Map<String, Object>) {
      writeInt(valMap);
      writeMap(val);
    } else if (val is Bundle) {
      // Must come before Parcelable
      writeInt(valBundle);
      writeBundle(val);
    } else if (val is Parcelable) {
      // Classes that implement Parcelable must come before this
      writeInt(valParcelable);
      writeParcelable(val, 0);
    } else if (val is int) {
      writeInt(valLong);
      writeLong(val);
    } else if (val is double) {
      writeInt(valDouble);
      writeDouble(val);
    } else if (val is bool) {
      writeInt(valBoolean);
      writeBoolean(val);
    } else if (val is Float64List) {
      // Must come before List
      writeInt(valDoubleArray);
      writeDoubleArray(val);
    } else if (val is Uint8List) {
      // Must come before List
      writeInt(valByteArray);
      writeByteArray(val);
    } else if (val is Int32List) {
      // Must come before List
      writeInt(valIntArray);
      writeIntArray(val);
    } else if (val is Int64List) {
      // Must come before List
      writeInt(valLongArray);
      writeLongArray(val);
    } else if (val is List<bool>) {
      // Must come before List
      writeInt(valBooleanArray);
      writeBooleanArray(val);
    } else if (val is List<String>) {
      // Must come before List
      writeInt(valStringArray);
      writeStringArray(val);
    } else if (val is List<Object>) {
      writeInt(valList);
      writeList(val);
    } else {
      throw ArgumentError("Parcel: unable to marshal value $val");
    }
  }

  void writeBoolean(final bool val) {
    writeInt(val ? 1 : 0);
  }

  void writeFloat(final double val) {
    _buffer.setFloat32(0, val, Endian.host);
    _write(_bufferAsList, 0, 4);
  }

  void writeDouble(final double val) {
    _buffer.setFloat64(0, val, Endian.host);
    _write(_bufferAsList, 0, 8);
  }

  void writeByte(final int val) {
    writeInt(val);
  }

  void writeInt(final int val) {
    _buffer.setInt32(0, val, Endian.host);
    _write(_bufferAsList, 0, 4);
  }

  void writeLong(final int val) {
    _buffer.setInt64(0, val, Endian.host);
    _write(_bufferAsList, 0, 8);
  }

  void writeString(final String? val) {
    if (val == null) {
      return writeInt(-1);
    }
    writeInt(val.length);
    _write(Int16List.fromList(val.codeUnits) // TODO: optimize this
        .buffer
        .asUint8List());
  }

  void writeBooleanArray(final List<bool>? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    for (var val in vals) {
      writeBoolean(val);
    }
  }

  void writeFloatArray(final Float32List? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    _write(vals.buffer.asUint8List(vals.offsetInBytes, 4 * vals.length));
  }

  void writeDoubleArray(final Float64List? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    _write(vals.buffer.asUint8List(vals.offsetInBytes, 8 * vals.length));
  }

  void writeByteArray(final Uint8List? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    _write(vals);
  }

  void writeCharArray(final Int16List? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    // Can't use buffer.putInt16List() because Android uses writeInt()
    for (var val in vals) {
      writeInt(val);
    }
  }

  void writeIntArray(final Int32List? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    _write(vals.buffer.asUint8List(vals.offsetInBytes, 4 * vals.length));
  }

  void writeLongArray(final Int64List? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    _write(vals.buffer.asUint8List(vals.offsetInBytes, 8 * vals.length));
  }

  void writeStringArray(final List<String>? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    for (var val in vals) {
      writeString(val);
    }
  }

  void writeList(final List<Object>? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    for (var val in vals) {
      writeValue(val);
    }
  }

  void writeMap(final Map<String, Object>? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    vals.forEach((key, val) {
      writeValue(key);
      writeValue(val);
    });
  }

  void writeArrayMap(final Map<String, Object>? vals) {
    if (vals == null) {
      return writeInt(-1);
    }
    writeInt(vals.length);
    vals.forEach((key, val) {
      writeString(key);
      writeValue(val);
    });
  }

  void writeBundle(final Bundle? bundle) {
    if (bundle == null) {
      return writeInt(-1);
    }
    bundle.writeToParcel(this);
  }

  void writeParcelable(final Parcelable? parcelable, [int parcelableFlags = 0]) {
    if (parcelable == null) {
      return writeString(null);
    }
    writeString(parcelable.parcelableCreator);
    parcelable.writeToParcel(this, parcelableFlags);
  }

  void _write(final Uint8List? data, [int start = 0, int end = 0]) {
    if (data == null) return;
    _output.addAll(data, start, end);
    if (_output.lengthInBytes % 4 != 0) {
      _writePadding(4 - _output.lengthInBytes % 4);
    }
  }

  void _writePadding(final int count) {
    for (var i = 0; i < count; i++) {
      _output.add(0);
    }
  }

  ByteData asByteData() {
    return _output.buffer.asByteData(0, _output.lengthInBytes);
  }

  Uint8List asUint8List() {
    return Uint8List.sublistView(asByteData());
  }
}
