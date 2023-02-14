import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:selecaosicoob/bin/pages/usuario/usuario_page_controller.dart';

import '../../model/project_info_model.dart';
import '../../model/setor_model.dart';

class ViewListUsuario extends StatefulWidget {
  const ViewListUsuario({super.key});

  @override
  State<ViewListUsuario> createState() => _ViewListUsuarioState();
}

class _ViewListUsuarioState extends State<ViewListUsuario> {
  UsuarioController usuarioController = UsuarioController(initialLoad: true);
  late UsuarioPageController pageController;

  @override
  void initState() {
    pageController = UsuarioPageController(usuarioController);
    super.initState();
  }

  _buildTitle() {
    return Text('${GetIt.instance<ProjectInfo>().nome} - Usuarios');
  }

  Widget _buildSearchField() {
    return Container(
      color: Colors.white,
      child: TextField(
        controller: pageController.searchQueryController,
        autofocus: true,
        //style: Theme.of(context).textTheme.bodyMedium,
        decoration: const InputDecoration(
          hintText: "Pesquisar ...",
          //hintStyle: Theme.of(context).textTheme.bodyMedium,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        onChanged: (query) => pageController.updateSearchQuery(query),
        onSubmitted: (value) => pageController.search(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(size.width, 60),
        child: AnimatedBuilder(
          animation: pageController,
          builder: (context, child) {
            return AppBar(
              leading: !pageController.isSearching
                  ? const BackButton()
                  : Container(),
              title: pageController.isSearching
                  ? _buildSearchField()
                  : _buildTitle(),
              actions: [
                IconButton(
                  icon: pageController.isSearching
                      ? const Icon(Icons.clear)
                      : const Icon(Icons.search),
                  onPressed: () {
                    if (!pageController.isSearching) {
                      pageController.setSearching();
                    } else {
                      pageController.stopSearching();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    pageController.novo(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: usuarioController,
            builder: (context, child) {
              if (usuarioController.isLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (usuarioController.hasError) {
                return Expanded(
                  child: Center(
                    child: Text(
                        'Ops, Não conseguimos carregar os dados.\r\n${usuarioController.error}'),
                  ),
                );
              } else if (usuarioController.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: usuarioController.dados.length,
                    itemBuilder: (context, index) {
                      Usuario usuario = usuarioController.dados[index];
                      return ListTile(
                        title: Text(usuario.nome),
                        subtitle: Text('${usuario.email}\r\n${usuario.codigo}'),
                        onTap: () {},
                        leading: const Icon(Icons.work_history),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'editar') {
                              pageController.novo(
                                context,
                                data: usuario,
                              );
                            }

                            if (value == 'setores') {
                              SetorController setorController =
                                  SetorController();
                              setorController.getData().then((value) {
                                pageController.setSetores(
                                  context,
                                  usuario,
                                  setorController.listaSetor,
                                );
                              });
                            }
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem(
                                value: 'editar',
                                child: Text("Editar"),
                              ),
                              PopupMenuItem(
                                value: 'setores',
                                child: Text("Setores"),
                              ),
                            ];
                          },
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Expanded(
                  child: Center(
                    child: Text('Não há dados'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/*
IconButton(
                          onPressed: () {
                           
                          },
                          icon: const Icon(Icons.edit),
                        )
*/
