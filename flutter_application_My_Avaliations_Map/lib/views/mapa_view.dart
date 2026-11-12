import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/mapa_controller.dart';
import '../models/avaliacao.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key, required this.title});

  final String title;

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  final MapaController _controller = MapaController();
  TextEditingController? _comentarioAvaliacaoController;
  TextEditingController? _apelidoAvaliacaoController;
  GoogleMapController? _mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apelidoAvaliacaoController = TextEditingController();
    _comentarioAvaliacaoController = TextEditingController();
    _controller.carregarLocalizacao();
    unawaited(_carregarAvaliacoesSalvas());
  }

  Future<void> _carregarAvaliacoesSalvas() async {
    await _controller.carregarAvaliacoes(
      aoTocarAvaliacao: _mostrarDetalhesAvaliacao,
    );

    if (!mounted) return;
    final erro = _controller.erroPersistencia;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível carregar avaliações: $erro')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapController?.dispose();
    _apelidoAvaliacaoController?.dispose();
    _comentarioAvaliacaoController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTyped(LatLng pontoClicado) {
    _controller.atualizarPosicaoSelecionada(pontoClicado);
  }

  Widget _classificacaoEstrelas(StateSetter atualizarDialogo) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            atualizarDialogo(() {
              _controller.avaliacao = index + 1;
            });
          },
          icon: Icon(
            Icons.star,
            color: index < _controller.avaliacao ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }

  void _mostrarDetalhesAvaliacao(Avaliacao avaliacao) {
    final estrelas = '★' * avaliacao.nota + '☆' * (5 - avaliacao.nota);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(avaliacao.apelido),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(estrelas),
                const SizedBox(height: 12),
                Text(avaliacao.comentario),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarFormulario() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, atualizarDialogo) {
            return AlertDialog(
              title: Text('Avaliar local'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sua avaliação'),
                  _classificacaoEstrelas(atualizarDialogo),
                  TextField(
                    controller: _apelidoAvaliacaoController,
                    decoration: InputDecoration(
                      labelText: 'Apelido',
                      hintText: 'Ex.: Minha casa',
                    ),
                  ),
                  TextField(
                    controller: _comentarioAvaliacaoController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'O que achou desse lugar?',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _comentarioAvaliacaoController?.clear();
                    _apelidoAvaliacaoController?.clear();
                    _controller.avaliacao = 0;
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final apelido = _apelidoAvaliacaoController!.text;
                    final comentario = _comentarioAvaliacaoController!.text;
                    final avaliacao = _controller.avaliacao;

                    try {
                      await _controller.salvarFormulario(
                        apelido,
                        comentario,
                        avaliacao,
                        aoTocarAvaliacao: _mostrarDetalhesAvaliacao,
                      );
                    } catch (erro) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('Não foi possível salvar: $erro'),
                        ),
                      );
                      return;
                    }

                    if (!mounted) return;
                    _comentarioAvaliacaoController?.clear();
                    _apelidoAvaliacaoController?.clear();
                    _controller.avaliacao = 0;
                    Navigator.pop(context);
                  },
                  child: Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.erro != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Não foi possível carregar sua localização.'),
                    const SizedBox(height: 8),
                    Text(_controller.erro!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _controller.carregarLocalizacao,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posicao = _controller.posicaoAtual;
          if (posicao == null) {
            return const Center(child: Text('Localização indisponível.'));
          }

          final temLocalSelecionado = _controller.posicaoSelecionada != null;

          return Stack(
            children: [
              GoogleMap(
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: posicao,
                  zoom: 20,
                ),
                onMapCreated: _onMapCreated,
                mapType: _controller.tipoMapa,
                markers: _controller.marcadores,
                onTap: (ponto) => _onMapTyped(ponto),
                // myLocationButtonEnabled: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 60,
                  horizontal: 10,
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    spacing: 16.0,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _controller.alternarTipoMapa,
                          icon: const Icon(
                            Icons.layers_outlined,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: temLocalSelecionado
                              ? Colors.white
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _controller.posicaoSelecionada == null
                              ? null
                              : _mostrarFormulario,
                          icon: Icon(
                            Icons.star_outline,
                            color: temLocalSelecionado
                                ? Colors.black87
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
