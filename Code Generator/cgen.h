#include <stdio.h>
#include <assert.h>
#include <typeinfo>

#include <functional>
#include <algorithm>

#include <list>
#include <string>
#include <map>
#include <vector>

#include "emit.h"
#include "cool-tree.h"
#include "symtab.h"

enum Basicness     {Basic, NotBasic};
#define TRUE 1
#define FALSE 0

class CgenClassTable;
typedef CgenClassTable *CgenClassTableP;

class CgenNode;
typedef CgenNode *CgenNodeP;

template<class Elem>
ostream& code_lookup_entry(StringTable<Elem> table, char *s, ostream& o);

template<class Entry>
ostream& code_entry(Entry entry, ostream& o);

template <typename FeatureType>
struct FeatureElem {
  CgenNode *owner; 
  FeatureType *feature;
};

template <typename FeatureType>
class FeatureCol: public std::list<FeatureElem<FeatureType>> {
   int _get_offset(Symbol);
public:
   int get_offset(Symbol);
   FeatureType* get(Symbol);
};

class VarBinding {
protected:
   char *reg;
   int offset;
public:
   VarBinding() : reg(ACC), offset(0) {}
   VarBinding(char *_reg, int _offset) : reg(_reg), offset(_offset) {}
   char *get_reg() { return reg; }
   virtual int get_offset() = 0; 
   void emit_load_from(ostream &s, char* = ACC);
   void emit_store_into(ostream &s, char* = ACC);
};

class AttrBinding: public VarBinding {
public:
   AttrBinding(int _offset) : VarBinding(SELF, _offset) {}
   int get_offset() { return 3 + offset; } 
};

class FormalBinding: public VarBinding {
public:
   FormalBinding(int _offset) : VarBinding(FP, _offset) {}
   int get_offset() { return (1 + 3 + offset); } 
};

class LocalBinding: public VarBinding {
public:
   LocalBinding(int _offset) : VarBinding(FP, _offset) {}
   int get_offset() { return -offset; }
};

enum BindingType {
   AttrBindType,
   FormalBindType,
   LocalBindType,
};

class FunctionContext : public SymbolTable<Symbol, VarBinding> {
public:
   int attr_count;
   int formal_count;
   int local_count;

   FunctionContext() : attr_count(0), formal_count(0), local_count(0) {}
   
   void add(Symbol _var, BindingType _type);
   void exitscope(BindingType _type);
};

struct InheritanceRange {
   int min;
   int max;
};

class CgenClassTable : public SymbolTable<Symbol,CgenNode> {
private:
   List<CgenNode> *nds;
   ostream& str;
   int stringclasstag;
   int intclasstag;
   int boolclasstag;


// The following methods emit code for
// constants and global declarations.

   void code_global_data();
   void code_global_text();
   void code_bools(int);
   void code_select_gc();
   void code_constants();

// The following creates an inheritance graph from
// a list of classes.  The graph is implemented as
// a tree of `CgenNode', and class names are placed
// in the base class symbol table.

   void install_basic_classes();
   void install_class(CgenNodeP nd);
   void install_classes(Classes cs);
   void build_inheritance_tree();
   void set_relations(CgenNodeP nd);
   
   void protObjs_attr(attr_class *);
public:
   int label_no;
   Symbol _class;
   FunctionContext fn_ctx;

   CgenClassTable(Classes, ostream& str);
   void code();
   CgenNodeP root();

   void class_nameTab();
   void class_objTab();
   void protObjs();
   void dispTabs();
   void inits();
   void methods();

   CgenNodeP get_class(Symbol);
   int get_class_tag(Symbol);
   std::map<Symbol, int> get_class_tags();
   InheritanceRange get_inheritance_range(Symbol _class);
};

class CgenNode : public class__class {
private: 
   CgenNodeP parentnd;                        // Parent of class
   List<CgenNode> *children;                  // Children of class
   Basicness basic_status;                    // `Basic' if class is basic
                                              // `NotBasic' otherwise

public:
   CgenNode(Class_ c,
            Basicness bstatus,
            CgenClassTableP class_table);

   void add_child(CgenNodeP child);
   List<CgenNode> *get_children() { return children; }
   void set_parentnd(CgenNodeP p);
   CgenNodeP get_parentnd() { return parentnd; }
   int basic() { return (basic_status == Basic); }

   FeatureCol<attr_class> get_this_attrs();
   FeatureCol<attr_class> get_all_attrs();

   FeatureCol<method_class> get_this_methods();
   FeatureCol<method_class> get_all_methods();

   InheritanceRange get_inheritance_range(const std::map<Symbol, int> &tags_cache);
};

class BoolConst 
{
 private: 
  int val;
 public:
  BoolConst(int);
  void code_def(ostream&, int boolclasstag);
  void code_ref(ostream&) const;
};

#define provided_list_iter(list) \
for (int i = list->first(); list->more(i); i = list->next(i))

#define provided_list_r_iter(list) \
for (int i = list->len()-1; i >= 0; --i)

#define nodes_iter(stmts) \
  std::function<void(List<CgenNode> *)> recurse; \
  int i = 0; \
  bool early_break = false; \
  recurse = [&](auto node) { \
      if (node != nullptr) { \
         CgenNode* _class = node->hd(); \
         if (!early_break) \
            recurse(node->tl()); \
         stmts \
         i++; \
      } \
  }; \
  recurse(this->nds)

#define features_iter(stmts) \
   provided_list_iter(this->features) { \
      Feature feature = this->features->nth(i); \
      stmts \
   }