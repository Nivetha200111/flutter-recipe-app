import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Georgia',
        primarySwatch: Colors.deepPurple,
        textTheme: const TextTheme(
       displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
       titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
       bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    )
      ),
      home: const RecipeListScreen(),
    );
  }
}

class Recipe {
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
  });
}

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  RecipeListScreenState createState() => RecipeListScreenState();
}

class RecipeListScreenState extends State<RecipeListScreen> {
  List<Recipe> recipes = [];

  void _addRecipe(Recipe recipe) {
    setState(() {
      recipes.add(recipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            title: Text(recipe.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newRecipe = await Navigator.push<Recipe?>(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
          );
          if (newRecipe != null) {
            _addRecipe(newRecipe);
          }
        },
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              File(recipe.imageUrl),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            const Text('Ingredients:', style: TextStyle(fontSize: 20)),
            for (final ingredient in recipe.ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $ingredient'),
              ),
            const SizedBox(height: 8),
            const Text('Steps:', style: TextStyle(fontSize: 20)),
            for (final step in recipe.steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $step'),
              ),
          ],
        ),
      ),
    );
  }
}

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _imageUrl = '';
  String _ingredients = '';
  String _steps = '';
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName.jpg');

      setState(() {
        _imageFile = savedImage;
        _imageUrl = savedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 8),
              Text('Image:'),
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Select Image'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ingredients (separated by commas)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ingredients';
                  }
                  return null;
                },
                onSaved: (value) => _ingredients = value!,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Steps (separated by commas)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter steps';
                  }
                  return null;
                },
                onSaved: (value) => _steps = value!,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final newRecipe = Recipe(
                        title: _title,
                        imageUrl: _imageUrl,
                        ingredients: _ingredients.split(',').map((ingredient) => ingredient.trim()).toList(),
                        steps: _steps.split(',').map((step) => step.trim()).toList(),
                      );
                      Navigator.pop(context, newRecipe);
                    }
                  },
                  child: const Text('Add Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

