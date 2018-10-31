VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "AdodbInterface"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'//----------------------------------------------------------------------------
'// AdodbInterface�N���X
'//----------------------------------------------------------------------------

Option Explicit

'//----------------------------------------------------------------------------
'// �y�g�p��z
'//  �@�C���X�^���X����
'//�@�Aopen_oracle�F�I���N���ւ̐ڑ� or open_access�F�A�N�Z�X�ւ̐ڑ�
'//�@�Bexcute_sql or excute_sql_and_paste_recordset�FSQL�̎��s��f�[�^�\��t��
'//�@�Cpaste_recordset�F���s����SQL�ɂ��擾�����f�[�^��\��t��
'//�@�Dclose_connection�FDB�ւ̐ؒf
'//----------------------------------------------------------------------------

'// ��`�G���[�������͎Q�Ɛݒ��[Microsoft ActiveX Data Objects x.x Library]���I������Ă��邩�m�F
Private con As Adodb.Connection
Private rs As Adodb.Recordset

Private driver As String
Private netservicename As String
Private dsn As String
Private username As String
Private password As String

'//----------------------------------------------------------------------------
'// �@�\    �F�R���X�g���N�^
'// ���l    �F
'//----------------------------------------------------------------------------
Private Sub Class_Initialize()
    
    Set con = New Adodb.Connection
    Set rs = New Adodb.Recordset
    
    
End Sub

'//----------------------------------------------------------------------------
'// �@�\    �F�I���N���ւ̐ڑ�����
'// ���l    �F�ڑ����[�h 1 �F �h���C�o�[���E�l�b�g�T�[�r�X�����w
'//�@�@�@�@�@ �@�@�@�@�@ 2 �F �f�[�^�\�[�X�����w��
'//----------------------------------------------------------------------------
Public Sub open_oracle(ByVal driver_ As String, netservicename_ As String, dsn_ As String, username_ As String, password_ As String, connect_mode_ As Long)
    
    Dim constr As String

    driver = "{" & driver_ & "}"        'ex.�h���C�o���iMicrosoft�А��j��{Microsoft ODBC for Oracle}, �h���C�o���iOracle�А��j��{Oracle in OraDb11g_home1}
    netservicename = netservicename_    'tnsnames.ora �t�@�C���̃l�b�g�T�[�r�X��'
    dsn = dsn_                          '�f�[�^�\�[�X��
    username = username_                '�ڑ�����f�[�^�x�[�X�̃��[�U�[��
    password = password_                '�p�X���[�h

    '�h���C�o�[���E�l�b�g�T�[�r�X�����w�肷��ꍇ
    If connect_mode_ = 1 Then
        constr = "DRIVER=" & driver
        constr = constr & ";CONNECTSTRING=" & netservicename
        constr = constr & ";UID=" & username
        constr = constr & ";PWD=" & password & ";"
    ElseIf connect_mode_ = 2 Then
        '�f�[�^�\�[�X�����w�肷��ꍇ
        constr = "DSN=" & dsn
        constr = constr & ";UID=" & username
        constr = constr & ";PWD=" & password
    Else
        MsgBox "�p�ӂ���Ă��Ȃ�DB�ڑ����[�h���w�肳��Ă��܂��B" & Chr(13) & "�ݒ���m�F���ĉ������B"
    End If
    
    Debug.Print (constr)
    con.ConnectionString = constr
    con.Open
    Debug.Print "�I���N���ւ̐ڑ�����"
    
End Sub

'//----------------------------------------------------------------------------
'// �@�\    �F�A�N�Z�X�ւ̐ڑ�����
'// ���l    �F���� access_name_ �̓t�H���_���{�t�@�C����
'//----------------------------------------------------------------------------
Public Sub open_access(ByVal access_name_ As String)
     
    con.Open "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & access_name_ & ";" 'Access�t�@�C���ɐڑ�
    Debug.Print "�A�N�Z�X�ւ̐ڑ�����"
     
End Sub

'//----------------------------------------------------------------------------
'// �@�\    �FSQL�̎��s
'// ���l    �F
'//----------------------------------------------------------------------------
Public Sub excute_sql(ByVal str_sql_ As String)
    
    On Error GoTo err_
    
    '// UPDATE�����g�p����ۂ́A���O��COMMIT�����Ă����Ȃ��ƃG���[�ɂȂ邽�ߒ���
    Debug.Print str_sql_ & " �����s���܂��B"
    rs.Open str_sql_, con
    
    Exit Sub

err_:
    '// �G���[�������̓��[���o�b�N����
    con_rollbacktrans
    Debug.Print "�G���[�����������̂Ń��[���o�b�N���������{���܂����B"
    MsgBox "�G���[�ԍ�:" & Err.Number & Chr(13) & "�G���[���e:" & Err.Description
    Debug.Print "excute_sql:�v���O�������I�����܂��B"
    End

End Sub


'//----------------------------------------------------------------------------
'// �@�\    �F���s����SQL�Ŏ擾�������R�[�h�Z�b�g��Excel�ɓ\��t��
'// ���l    �Fis_filed_ �FTrue�Ńt�B�[���h������������
'//----------------------------------------------------------------------------
Private Sub paste_recordset(ByVal sheet_name_ As String, data_start_row_ As Long, data_start_col_ As Long, is_filed_ As Boolean)

    Dim i As Long

    If is_filed_ = True Then

        '�t�B�[���h���̏����o��
        For i = 0 To rs.Fields.count - 1
            ThisWorkbook.Worksheets(sheet_name_).Cells(data_start_row_, data_start_col_ + i).Value = rs.Fields(i).Name
        Next i
        
        data_start_row_ = data_start_row_ + 1
    
    End If
    
    'CopyFromRecordset���\�b�h�Ŋ�Z�����w�肵�ăf�[�^�̏����o��
    ThisWorkbook.Worksheets(sheet_name_).Cells(data_start_row_, data_start_col_).CopyFromRecordset rs

End Sub

'//----------------------------------------------------------------------------
'// �@�\    �FSQL�����s���A�����Ď擾�������R�[�h�Z�b�g��Excel�ɓ\��t��
'// ���l    �Fis_filed_ �FTrue�Ńt�B�[���h������������
'//----------------------------------------------------------------------------
Public Sub excute_sql_and_paste_recordset(ByVal str_sql_ As String, sheet_name_ As String, data_start_row_ As Long, data_start_col_ As Long, is_filed_ As Boolean)

    excute_sql str_sql_
    paste_recordset sheet_name_, data_start_row_, data_start_col_, is_filed_

End Sub


'//----------------------------------------------------------------------------
'// �@�\    �F�g�����U�N�V�����J�n����
'// ���l    �F
'//----------------------------------------------------------------------------
Public Sub con_begintrans()

    con.BeginTrans
    Debug.Print "�g�����U�N�V�����J�n"
    
End Sub

'//----------------------------------------------------------------------------
'// �@�\    �F�R�~�b�g�����iDB�ւ̏������݊����j
'// ���l    �F
'//----------------------------------------------------------------------------
Public Sub con_committrans()
    
    con.CommitTrans
    Debug.Print "�R�~�b�g�������{"

End Sub

'//----------------------------------------------------------------------------
'// �@�\    �F���[���o�b�N����
'// ���l    �F
'//----------------------------------------------------------------------------
Public Sub con_rollbacktrans()
    
    con.RollbackTrans
    Debug.Print "���[���o�b�N�������{"

End Sub

'//----------------------------------------------------------------------------
'// �@�\    �FDB�ւ̐ڑ��I������
'// ���l    �F
'//----------------------------------------------------------------------------
Public Sub close_connection()

    On Error Resume Next

    con.Close
    rs.Close
    
    Set con = Nothing
    Set rs = Nothing
    
    On Error GoTo 0 '// �G���[�����̖��ߎ�����
    Debug.Print "DB�ւ̐ؒf����"

End Sub

'//----------------------------------------------------------------------------
'// �@�\    �FINSERT �������� UPDATE ��SQL���쐬
'// ���l    �F�����͉��L
'//           �e�[�u�����A�V�[�g���ASQL�^�C�v�w��s�A�f�[�^�x�[�X�J�������w��s
'//           �f�[�^�i�[�J�n�s�A�f�[�^�i�[�J�n��A�f�[�^�i�[�I����
'// �@�@      �iSQL�^�C�v�FINWERT or UPDATE or WHERE�j
'//----------------------------------------------------------------------------
Public Function make_sql(table_name As String, sheet_name As String, sql_type_defined_row As Long, db_col_name_defined_row As Long _
    , data_start_row As Long, data_start_col As Long, data_end_col As Long) As String

    Dim i As Long, j As Long
    Dim start_row As Long
    Dim start_col As Long, end_col As Long
    
    Dim sql_mode As Long    '//1:�G���[�I���@2:INSERT�@3:UPDATE
    Dim sqltype As String
    Dim sql As String, sql_1 As String, sql_2 As String
    
    start_row = data_start_row

    start_col = data_start_col
    end_col = data_end_col
    
    sql_mode = 1    '// SQL���[�h���w�肳��Ȃ���΃G���[�I��
    sqltype = ThisWorkbook.Worksheets(sheet_name).Cells(sql_type_defined_row, start_col).Value
    Select Case sqltype
        Case "INSERT"
            sql_mode = 2

        Case "UPDATE"
            sql_mode = 3
    
        Case "WHERE"
            sql_mode = 3
    End Select
    
    i = start_row
    If sql_mode = 2 Then    '//1:�G���[�I���@2:INSERT�@3:UPDATE
    
        '// INSERT���̐���
        
        '// SQL��������
        sql = ""
        sql_1 = "INSERT INTO " & table_name & " ("
        sql_2 = "VALUES ("
    
        For j = start_col To end_col
    
            '// DB�J��������ǉ�
            sql_1 = sql_1 & ThisWorkbook.Worksheets(sheet_name).Cells(db_col_name_defined_row, j).Value
            If j <> end_col Then
                sql_1 = sql_1 & ", "
            Else
                sql_1 = sql_1 & ") "
            End If
            
            '// DB�J�������ɑ΂���l��ǉ�
            sql_2 = sql_2 & "'" & ThisWorkbook.Worksheets(sheet_name).Cells(i, j).Value & "'"
            If j <> end_col Then
                sql_2 = sql_2 & ", "
            Else
                sql_2 = sql_2 & ") "
            End If
            
        Next
        
        sql = sql_1 + sql_2
                
    ElseIf sql_mode = 3 Then
    
        '// UPDATE���̐���
                    
        '// SQL��������
        sql = ""
        sql_1 = "UPDATE " & table_name & " SET "
        sql_2 = "WHERE "
    
        For j = start_col To end_col
    
            If ThisWorkbook.Worksheets(sheet_name).Cells(sql_type_defined_row, j).Value = "UPDATE" Then
    
                '// UPDATE����DB�J�������ƒl��ǉ�
                sql_1 = sql_1 & ThisWorkbook.Worksheets(sheet_name).Cells(db_col_name_defined_row, j).Value & " = '" _
                     & ThisWorkbook.Worksheets(sheet_name).Cells(i, j).Value & "'"
                If j <> end_col Then
                    sql_1 = sql_1 & ", "
                Else
                    sql_1 = sql_1 & " "
                End If
                                
            ElseIf ThisWorkbook.Worksheets(sheet_name).Cells(sql_type_defined_row, j).Value = "WHERE" Then
            
                '// WHERE�ɑ΂���DB�J�������ƒl��ǉ�
                sql_2 = sql_2 & ThisWorkbook.Worksheets(sheet_name).Cells(db_col_name_defined_row, j).Value & " = '" _
                     & ThisWorkbook.Worksheets(sheet_name).Cells(i, j).Value & "'"
                If j <> end_col Then
                    sql_2 = sql_2 & " AND "
                Else
                    sql_2 = sql_2 & " "
                End If
            
            Else
                Debug.Print ("UPDATE���ɑ΂��āASQL�^�C�v�ݒ肪����������܂���B�ݒ���������ĉ������B")
                make_sql = ""
                Exit Function
            End If
        Next
        
        sql = Replace(sql_1 + sql_2, ", WHERE", " WHERE")
        If Right(sql, 1) = "," Then sql = Mid(sql, 1, Len(sql) - 1)
        If Right(sql, 5) = " AND " Then sql = Mid(sql, 1, Len(sql) - 5)
    
    Else
        Debug.Print ("SQL�������[�h�ɑ΂��āASQL�^�C�v�ݒ肪����������܂���B" & Chr(13) & "�v���O�������������ĉ������B")
        make_sql = ""
        Exit Function
    End If
    
    make_sql = sql
        
End Function

'//----------------------------------------------------------------------------
'// �@�\    �FINSERT �������� UPDATE ��SQL���쐬���Ď��s
'// ���l    �F
'//----------------------------------------------------------------------------
Public Sub make_and_excute_sql(table_name As String, sheet_name As String, sql_type_defined_row As Long, db_col_name_defined_row As Long _
    , data_start_row As Long, data_start_col As Long, data_end_col As Long)

    Dim sql As String

   '// �g�����U�N�V�����J�n
    con_begintrans

    '// SQL�쐬
    sql = make_sql(table_name, sheet_name, sql_type_defined_row, db_col_name_defined_row, data_start_row, data_start_col, data_end_col)
    
    '// SQL���s
    excute_sql sql
    
    '// �R�~�b�g����
    con_committrans
    
End Sub

'//----------------------------------------------------------------------------
'// �@�\    �F�A������INSERT �������� UPDATE ��SQL���쐬���Ď��s
'// ���l    �F
'//----------------------------------------------------------------------------
Public Sub make_and_excute_sqls(table_name As String, sheet_name As String, sql_type_defined_row As Long, db_col_name_defined_row As Long _
    , data_start_row As Long, data_start_col As Long, data_end_col As Long)

    Dim i As Long
    Dim sql As String
    Dim val
    Dim data_end_row As Long

    '// �f�[�^�̍ŏI�s������
    i = 1
    Do While ThisWorkbook.Worksheets(sheet_name).Cells(data_start_row + i, data_start_col) <> ""
        i = i + 1
    Loop
    
    data_end_row = data_start_row + i - 1

    '// �g�����U�N�V�����J�n
    con_begintrans
        
    For i = data_start_row To data_end_row

        '// SQL�쐬
        sql = make_sql(table_name, sheet_name, sql_type_defined_row, db_col_name_defined_row, i, data_start_col, data_end_col)
        '// SQL���s
        excute_sql sql
    
    Next
    
    '// �R�~�b�g����
    con_committrans
    
End Sub



