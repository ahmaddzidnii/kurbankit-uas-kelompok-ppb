import 'package:dio/dio.dart';

class MosqueRegistrationRequest {
  final String nama;
  final String? nomorSk;
  final String alamat;
  final String idDesa;
  final String? fotoMasjidPath;
  final String? fotoDokumenSkPath;

  MosqueRegistrationRequest({
    required this.nama,
    this.nomorSk,
    required this.alamat,
    required this.idDesa,
    this.fotoMasjidPath,
    this.fotoDokumenSkPath,
  });

  FormData toFormData() {
    final payload = <String, dynamic>{
      'id_desa': idDesa,
      'nama': nama,
      'alamat': alamat,
    };

    if (nomorSk != null && nomorSk!.isNotEmpty) {
      payload['nomor_sk'] = nomorSk;
    }

    if (fotoMasjidPath != null && fotoMasjidPath!.isNotEmpty) {
      payload['foto_masjid'] = MultipartFile.fromFileSync(
        fotoMasjidPath!,
        filename: _fileName(fotoMasjidPath!),
      );
    }

    if (fotoDokumenSkPath != null && fotoDokumenSkPath!.isNotEmpty) {
      payload['foto_dokumen_sk'] = MultipartFile.fromFileSync(
        fotoDokumenSkPath!,
        filename: _fileName(fotoDokumenSkPath!),
      );
    }

    return FormData.fromMap(payload);
  }

  String _fileName(String path) {
    return path.split(RegExp(r'[\\/]+')).last;
  }
}

class VerificationApprovalRequest {
  final String registrationId;
  final String approverNotes; // Optional notes from admin

  VerificationApprovalRequest({
    required this.registrationId,
    this.approverNotes = '',
  });

  Map<String, dynamic> toJson() {
    return {'registrationId': registrationId, 'approverNotes': approverNotes};
  }
}

class VerificationRejectionRequest {
  final String registrationId;
  final String rejectionReason;

  VerificationRejectionRequest({
    required this.registrationId,
    required this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'registrationId': registrationId,
      'rejectionReason': rejectionReason,
    };
  }
}

class MosqueTakedownRequest {
  final String mosqueId;
  final String reason; // Optional reason for takedown

  MosqueTakedownRequest({required this.mosqueId, this.reason = ''});

  Map<String, dynamic> toJson() {
    return {'mosqueId': mosqueId, 'reason': reason};
  }
}
