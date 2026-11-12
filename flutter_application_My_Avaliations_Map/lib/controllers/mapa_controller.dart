import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/avaliacao.dart';
import '../services/avaliacao_database.dart';

class MapaController extends ChangeNotifier {
  bool _carregando = true;
  String? _erro;
  String? _erroPersistencia;
  LatLng? _posicaoAtual;
  MapType _tipoMapa = MapType.normal;
  bool _descartado = false;

  LatLng? _posicaoSelecionada;
  Marker? _marcadorPosicaoSelecionada;

  int _avaliacao = 0;

  final Set<Marker> _marcadores = {
    Marker(
      markerId: const MarkerId('IFPI'),
      position: const LatLng(-5.1058, -42.8039),
      infoWindow: const InfoWindow(title: 'IFPI'),
    ),
    Marker(
      markerId: const MarkerId('IFPI-SUL'),
      position: const LatLng(-5.101723, -42.813114),
      infoWindow: const InfoWindow(title: 'IFPI SUL'),
    ),
  };

  bool get carregando => _carregando;
  String? get erro => _erro;
  String? get erroPersistencia => _erroPersistencia;
  LatLng? get posicaoAtual => _posicaoAtual;
  LatLng? get posicaoSelecionada => _posicaoSelecionada;
  MapType get tipoMapa => _tipoMapa;
  Set<Marker> get marcadores => Set.unmodifiable(_marcadores);

  int get avaliacao => _avaliacao;

  set avaliacao(int valor) {
    _avaliacao = valor;
  }

  Future<void> carregarLocalizacao() async {
    _carregando = true;
    _erro = null;
    _notificarMudanca();

    try {
      final position = await _determinePosition();
      _posicaoAtual = LatLng(position.latitude, position.longitude);
    } catch (erro) {
      _erro = erro.toString();
    } finally {
      _carregando = false;
      _notificarMudanca();
    }
  }

  void alternarTipoMapa() {
    _tipoMapa = _tipoMapa == MapType.normal
        ? MapType.satellite
        : MapType.normal;
    _notificarMudanca();
  }

  void atualizarPosicaoSelecionada(LatLng posicao) {
    _posicaoSelecionada = posicao;

    if (_marcadorPosicaoSelecionada != null) {
      _marcadores.remove(_marcadorPosicaoSelecionada);
    }
    _marcadorPosicaoSelecionada = Marker(
      markerId: const MarkerId('local-atual'),
      position: posicao,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    _marcadores.add(_marcadorPosicaoSelecionada!);
    _notificarMudanca();
  }

  Future<void> carregarAvaliacoes({
    required ValueChanged<Avaliacao> aoTocarAvaliacao,
  }) async {
    _erroPersistencia = null;

    try {
      final avaliacoes = await AvaliacaoDatabase.instance.listar();
      if (avaliacoes.isNotEmpty) {
        final icone = await _carregarIconeAvaliacao();
        for (final avaliacao in avaliacoes) {
          _marcadores.add(
            _criarMarcadorAvaliacao(avaliacao, icone, aoTocarAvaliacao),
          );
        }
      }
    } catch (erro) {
      _erroPersistencia = erro.toString();
    } finally {
      _notificarMudanca();
    }
  }

  Future<void> salvarFormulario(
    String apelido,
    String comentario,
    int avaliacao, {
    required ValueChanged<Avaliacao> aoTocarAvaliacao,
  }) async {
    if (apelido.trim().isEmpty) {
      throw ArgumentError('Informe um apelido para o local.');
    }
    if (comentario.trim().isEmpty) {
      throw ArgumentError('Informe um comentário para o local.');
    }
    if (avaliacao < 1 || avaliacao > 5) {
      throw ArgumentError('Selecione uma avaliação de 1 a 5 estrelas.');
    }

    final posicao = _posicaoSelecionada;
    if (posicao == null) {
      throw StateError('Selecione um ponto no mapa antes de salvar.');
    }

    final avaliacaoNova = Avaliacao(
      apelido: apelido,
      comentario: comentario,
      nota: avaliacao,
      latitude: posicao.latitude,
      longitude: posicao.longitude,
    );
    final iconeEstrela = await _carregarIconeAvaliacao();
    final id = await AvaliacaoDatabase.instance.inserir(avaliacaoNova);
    final avaliacaoSalva = Avaliacao(
      id: id,
      apelido: avaliacaoNova.apelido,
      comentario: avaliacaoNova.comentario,
      nota: avaliacaoNova.nota,
      latitude: avaliacaoNova.latitude,
      longitude: avaliacaoNova.longitude,
    );

    final novoMarcador = _criarMarcadorAvaliacao(
      avaliacaoSalva,
      iconeEstrela,
      aoTocarAvaliacao,
    );
    _marcadores.remove(_marcadorPosicaoSelecionada);
    _marcadorPosicaoSelecionada = null;
    _posicaoSelecionada = null;
    _marcadores.add(novoMarcador);
    _erroPersistencia = null;
    _notificarMudanca();
  }

  Future<BitmapDescriptor> _carregarIconeAvaliacao() {
    return BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/iconeEstrela.png',
    );
  }

  Marker _criarMarcadorAvaliacao(
    Avaliacao avaliacao,
    BitmapDescriptor icone,
    ValueChanged<Avaliacao> aoTocarAvaliacao,
  ) {
    final estrelas = '★' * avaliacao.nota + '☆' * (5 - avaliacao.nota);

    return Marker(
      markerId: MarkerId('local-${avaliacao.id}'),
      position: LatLng(avaliacao.latitude, avaliacao.longitude),
      infoWindow: InfoWindow(
        title: avaliacao.apelido,
        snippet: '$estrelas · Toque para ver comentário',
        onTap: () => aoTocarAvaliacao(avaliacao),
      ),
      icon: icone,
    );
  }

  void _notificarMudanca() {
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final Position position = await Geolocator.getCurrentPosition();
    debugPrint('Localização: $position');
    return position;
  }
}
