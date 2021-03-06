//+------------------------------------------------------------------+
//|                                       EATriangularSecundario.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/es/users/byron.mena.7"
#property version   "1.00"
#property strict

int nivel;
string orden;
bool nuevaOrdenControl;
input double Lote_inicial=0.01;
input double Lote_segunda_opcion=0.10;
input double Lote_tercera_opcion=0.25;
input int spillage=5;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Comment("\nIniciando: A la espera de un tick ...");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
   Leer();
   int i=0;
   switch(nivel){
    case 0:
     break;
    case 1:
     break;
    case 2:
     i=0;
     for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if(OrderSelect(pos, SELECT_BY_POS)==true)
       if(OrderSymbol()==Symbol())
        i++;
     }
     while(i<1){
      {
       NuevaOrden(Lote_inicial,orden);
       for(int pos=0; pos<OrdersTotal(); pos++)
       {
        if(OrderSelect(pos, SELECT_BY_POS)==true)
        if(OrderSymbol()==Symbol())
         i++;
       }
      }
     }
     break;
    case 3:
     i=0;
     for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if(OrderSelect(pos, SELECT_BY_POS)==true)
       if(OrderSymbol()==Symbol())
        i++;
     }
     while(i<2){
      {
       NuevaOrden(Lote_segunda_opcion,orden);
       for(int pos=0; pos<OrdersTotal(); pos++)
       {
        if(OrderSelect(pos, SELECT_BY_POS)==true)
        if(OrderSymbol()==Symbol())
         i++;
       }
      }
     }
     break;
    case 4:
     i=0;
     for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if(OrderSelect(pos, SELECT_BY_POS)==true)
       if(OrderSymbol()==Symbol())
        i++;
     }       
     while(i<3){
      {
       NuevaOrden(Lote_tercera_opcion,orden);
       for(int pos=0; pos<OrdersTotal(); pos++)
       {
        if(OrderSelect(pos, SELECT_BY_POS)==true)
        if(OrderSymbol()==Symbol())
         i++;
       }
      }
     }
     break;
   }
   int mostrar=nivel;
   Comment("\nOK\nNivel:",mostrar-1
   );
  }
//+------------------------------------------------------------------+

//Abrir nueva operación diferente a la principal
bool NuevaOrden(double volumen,string ordenDivisaPrincipal){
 int indicador=0;
 bool resultado=false;
 if(ordenDivisaPrincipal=="buy"){
  indicador=OrderSend(Symbol(),OP_SELL,volumen,MarketInfo(Symbol(),MODE_BID),spillage,MarketInfo(Symbol(),MODE_BID)+10000*_Point,0,NULL,0,0,Green);
  orden="sell";
 }
 if(ordenDivisaPrincipal=="sell"){
  indicador=OrderSend(Symbol(),OP_BUY,volumen,MarketInfo(Symbol(),MODE_ASK),spillage,0,MarketInfo(Symbol(),MODE_ASK)+10000*_Point,NULL,0,0,Green);
  orden="buy";
 }
 if(indicador==-1){
  PrintFormat("Error al abrir orden %s",GetLastError());
  resultado=false;
 }
 if(indicador>-1)
  resultado=true;
 return resultado;
}

//Cerrar operaciones
bool CerrarTodasLasOperaciones(){
 int total = OrdersTotal();
 bool result=false;
 for(int i=total-1;i>=0;i--)
 {
  int selectOrder = OrderSelect(i, SELECT_BY_POS);
  int type   = OrderType();
  result = false;
  
  switch(type)
  {
   //Cerrar posiciones largas
   case OP_BUY : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                 break;
      
   //Cerrar posiciones cortas
   case OP_SELL : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                  break;
  }
  
  if(result == false)
  {
   Print("Orden " , OrderTicket() , " error al cerrar. Error:" , GetLastError() );
   Sleep(1000);
  }  
 }
 return result;
}

//Leer archivo de configuración
bool Leer(){
 bool resultado=false;
 string InpFileName = "control.txt";
 int file_handle=FileOpen("//"+InpFileName,FILE_READ|FILE_WRITE|FILE_CSV,';');
 if(file_handle!=INVALID_HANDLE)
 {
  while(!FileIsEnding(file_handle)){
   nivel = (int)FileReadString(file_handle);
   orden = FileReadString(file_handle);
   nuevaOrdenControl =FileReadBool(file_handle);
   FileReadString(file_handle);
   /*
   if(nivel==0)
    PrintFormat("Error al leer el archivo %s ",GetLastError());
   if(nivel!=0)
    resultado=true;
    */
   FileClose(file_handle);
  }
  resultado=true;
 }
 else{
  PrintFormat("Error al abrir %s, Código de error = %d",InpFileName,GetLastError());
 }
 return resultado;
}