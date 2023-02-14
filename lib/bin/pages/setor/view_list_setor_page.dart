import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:selecaosicoob/bin/model/setor_model.dart';
import 'package:selecaosicoob/bin/pages/setor/setor_page_controller.dart';
import '../../model/project_info_model.dart';

class ViewListSetor extends StatefulWidget {
  const ViewListSetor({super.key});

  @override
  State<ViewListSetor> createState() => _ViewListSetorState();
}

class _ViewListSetorState extends State<ViewListSetor> {
  SetorController setorController = SetorController(loadSetores: true);
  late SetorPageController setorPageController;

  @override
  void initState() {
    setorPageController = SetorPageController(setorController);
    super.initState();
  }

  _buildTitle() {
    return Text('${GetIt.instance<ProjectInfo>().nome} - Setores');
  }

  Widget _buildSearchField() {
    return Container(
      color: Colors.white,
      child: TextField(
        controller: setorPageController.searchQueryController,
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
        onChanged: (query) => setorPageController.updateSearchQuery(query),
        onSubmitted: (value) => setorPageController.search(),
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
          animation: setorPageController,
          builder: (context, child) {
            return AppBar(
              leading: !setorPageController.isSearching
                  ? const BackButton()
                  : Container(),
              title: setorPageController.isSearching
                  ? _buildSearchField()
                  : _buildTitle(),
              actions: [
                IconButton(
                  icon: setorPageController.isSearching
                      ? const Icon(Icons.clear)
                      : const Icon(Icons.search),
                  onPressed: () {
                    if (!setorPageController.isSearching) {
                      setorPageController.setSearching();
                    } else {
                      setorPageController.stopSearching();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setorPageController.novoSetor(context);
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
            animation: setorController,
            builder: (context, child) {
              if (setorController.isLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (setorController.hasError) {
                return Expanded(
                  child: Center(
                    child: Text(
                        'Ops, Não conseguimos carregar os dados.\r\n${setorController.error}'),
                  ),
                );
              } else if (setorController.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: setorController.listaSetor.length,
                    itemBuilder: (context, index) {
                      Setor setor = setorController.listaSetor[index];
                      return ListTile(
                        title: Text(setor.descricao),
                        subtitle: Text(setor.codigo),
                        onTap: () {},
                        leading: const Icon(Icons.work_history),
                        trailing: IconButton(
                          onPressed: () {
                            setorPageController.novoSetor(
                              context,
                              setor: setor,
                            );
                          },
                          icon: const Icon(Icons.edit),
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
