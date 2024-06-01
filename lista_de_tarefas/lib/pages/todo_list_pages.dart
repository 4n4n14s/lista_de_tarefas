import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/model/tarefas.dart';
import 'package:lista_de_tarefas/repositories/tarefasRepositorio.dart';
import 'package:lista_de_tarefas/widgets/widgets.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController tarefasControler = TextEditingController();

  final TarefasRepositori tarefasrepositori = TarefasRepositori();

  List<Tarefas> tarefas = [];

  Tarefas? tarefadeletada;

  int? lugarTarefaDeletada;

  String? errorText;

  @override
  void initState() {
    super.initState();

    tarefasrepositori.getListaTarefas().then((value) {
      setState(() {
        tarefas = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tarefasControler,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            
                            labelText: 'adicione uma tarefa',
                            labelStyle: TextStyle(color: Colors.blue),
                            hintText: 'ex. Estudar',
                            errorText: errorText,
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2))),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        String tarefaTextField = tarefasControler.text;
                        if (tarefaTextField.isEmpty) {
                          setState(() {
                            errorText = 'o titulo não pode ser vazio';
                          });

                          return;
                        }

                        setState(() {
                          Tarefas novaTarefa = Tarefas(
                              title: tarefaTextField, dateTime: DateTime.now());
                          tarefas.add(novaTarefa);
                          errorText = null;
                          tarefasControler.clear();
                        });
                        tarefasrepositori.saveListaTarefas(tarefas);
                      },
                      child: Icon(Icons.add),
                    )
                  ],
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Tarefas item in tarefas)
                        TarefasListItens(tarefa: item, onDelete: onDelete)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('total de ${tarefas.length} tarefas')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(3))),
                        onPressed: deletarTodasTarefas,
                        child: Text(
                          'limpar',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Tarefas tarefa) {
    tarefadeletada = tarefa;
    lugarTarefaDeletada = tarefas.indexOf(tarefa);
    setState(() {
      tarefas.remove(tarefa);
    });
    tarefasrepositori.saveListaTarefas(tarefas);

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'tarefa ${tarefa.title} foi removida com sucesso!',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: Colors.blue,
        onPressed: () {
          setState(() {
            tarefas.insert(lugarTarefaDeletada!, tarefadeletada!);
          });
          tarefasrepositori.saveListaTarefas(tarefas);
        },
      ),
    ));
  }

  void deletarTodasTarefas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo? '),
        content: Text('Você tem certeza que deja apagar todas as tarefas? '),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'cancelar',
                style: TextStyle(color: Colors.blue),
              )),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteTodasTarefas();
            },
            child: Text(
              'limpar tudo',
              style: TextStyle(color: Colors.red),
            ),
            style: TextButton.styleFrom(
              overlayColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void deleteTodasTarefas() {
    setState(() {
      tarefas.clear();
    });
    tarefasrepositori.saveListaTarefas(tarefas);
  }
}
