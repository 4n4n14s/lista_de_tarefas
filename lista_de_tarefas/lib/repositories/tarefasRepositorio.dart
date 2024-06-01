import 'dart:convert';

import 'package:lista_de_tarefas/model/tarefas.dart';
import 'package:shared_preferences/shared_preferences.dart';

const todoListaChave = 'todo_list';

class TarefasRepositori {
  late SharedPreferences sharedPreferences;

  Future< List<Tarefas> > getListaTarefas() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString =
        sharedPreferences.getString(todoListaChave) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e)=>Tarefas.fromJson(e)).toList();
  }

  void saveListaTarefas(List<Tarefas> item) {
    String jsonString = json.encode(item);

    sharedPreferences.setString(todoListaChave, jsonString);
  }
}
